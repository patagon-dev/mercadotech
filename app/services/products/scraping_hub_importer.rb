class Products::ScrapingHubImporter < Products::Base
  ITEM_ATTRIBUTES = %w[sku partnumber name price stock image picture_url images manufacturer description solotodo
                       attributes variants etilize_id datasheet accessories similar_products solotodo_id].freeze
  ERROR_LOG_FILE = "ScrapingHubImportLog-#{Time.current}__.json".freeze

  attr_reader :full_spider, :default_stock_location

  def initialize(path, vendor_id, full_spider)
    super
    @full_spider = full_spider
    @default_stock_location = vendor.stock_locations.where(default: true).take
    @variant_images = {}
    @datasheet_files = {}
  end

  def process_import
    doc = Nokogiri::XML(File.open(path))
    rows = doc.xpath('./value/array/data/value/struct')

    rows.each do |row|
      members = row.xpath('./member')

      # Creating product row hash
      row_hash = members.map do |member|
        key = member.at('name').text
        key = 'partnumber' if key == 'part_number'
        next unless ITEM_ATTRIBUTES.include?(key)

        value = member.at('value').text.strip

        if %w[accessories similar_products images].include?(key)
          value = value.present? ? member.xpath('./value/array/data/value').map { |x| x.text.strip } : []
        end
        if %w[attributes solotodo datasheet].include?(key)
          value = member.at('value').xpath('./struct/member').map do |x|
            [x.at('name').text, x.at('value').text.strip]
          end.to_h
        end
        value = build_variants_data(member) if key == 'variants'
        value = bulid_stock_data(member) if key == 'stock'

        [key, value]
      end
                        .compact.to_h

      base_attributes = row_hash['attributes'] || {}
      solotodo = row_hash['solotodo'] || {}

      # Copying partnumber from properties to product
      unless row_hash['partnumber'].present?
        row_hash['partnumber'] = row_hash['attributes']['part_number'] if base_attributes.keys.include?('part_number')
        row_hash['partnumber'] = row_hash['solotodo']['part_number'] if solotodo.keys.include?('part_number')
      end

      formatted_sku = row_hash['sku']

      begin
        ::ActiveRecord::Base.transaction do
          next unless all_required_fields_exists?(row_hash) # validate all required fields

          # vendor id prefix with sku
          formatted_sku = "#{vendor_id}_#{row_hash['sku']}"
          variant = Spree::Variant.where(sku: formatted_sku, is_master: true).first

          if variant.present?
            product = variant.product
            next if product.skip_full_import && full_spider
            next if product.skip_quick_import && !full_spider

            if !full_spider || vendor.update_all_product
              attributes = product_attributes(row_hash)
              Searchkick.callbacks(false) do
                product.update!(attributes)
              end
            end
          elsif full_spider
            attributes = product_attributes(row_hash)
            product = Spree::Product.new(attributes)

            Searchkick.callbacks(false) do
              raise ProductNotCreatedError unless product.save
            end

            variant = product.master
          else
            raise VariantNotFoundError
          end


          if full_spider
            # uploading product datasheet pdf files on s3
            @datasheet_files[product.id.to_s.to_sym] = row_hash['datasheet'].to_a if row_hash['datasheet'].present?

            # Creating Relation for attributes accessories and similar_products with variant product.
            %w[accessories similar_products].each do |relation|
              next unless row_hash[relation].present?

              create_related_product(product, row_hash[relation], relation)
            end

            images = []
            images.push(row_hash['image']) if row_hash['image'].present?
            row_hash['images'] = [] unless row_hash['images'].present?
            row_hash['images'].push(row_hash['picture_url']) if row_hash['picture_url'].present?
            images = images.concat(row_hash['images'])

            @variant_images[variant.id.to_s] = images.uniq if images.present?

            save_variants(variant, row_hash['variants']) if row_hash['variants'].present?

            # product properties attributes
            item_attributes = base_attributes.merge!(solotodo)
            if row_hash['manufacturer'].present?
              item_attributes = item_attributes.merge!({ 'manufacturer' => row_hash['manufacturer'] })
            end
            if row_hash['partnumber'].present?
              item_attributes = item_attributes.merge!({ 'partnumber' => row_hash['partnumber'] })
            end

            save_item_attributes(variant, item_attributes) if item_attributes.present? # save item attributes
          else
            # save stock for default stock location
            save_variant_stock(variant,row_hash['stock']) if row_hash['stock'].present?
            save_product_variant_stock(row_hash['variants']) if row_hash['variants'].present?
          end

          @product_ids.push(product.id)
        end
      rescue VariantNotFoundError => e
        data = { sku: formatted_sku, message: e.message }
        log_data(:variant_not_found, data)
      rescue ProductNotCreatedError => e
        data = { sku: formatted_sku, message: e.message }
        log_data(:product_not_created, data)
      rescue ActiveRecord::RecordInvalid => e
        data = { sku: formatted_sku, message: e.message }
        log_data(:record_invalid, data)
      rescue Exception => e
        data = { sku: formatted_sku, message: e.message }
        log_data(:general, data)
      end
    end

    if full_spider
      process_image_upload
      process_datasheet_upload
    end
    vendor.update_column(:scrapinghub_imported_at, Time.now)
    write_log_file
    send_vendor_notification if @import_errors.present?
    attached_log_file_to_vendor if @import_errors.present?
  end

  def create_related_product(base_product, partnumbers, relation)
    rt_name = (relation.include? 'products') ? relation : 'accessories_products'
    relation_type = Spree::RelationType.find_or_create_by(name: rt_name,
                                                          applies_to: 'Spree::Product')
    create_relation(base_product, relation_type, partnumbers) if relation_type.present?
  end

  def create_relation(base_product, relation_type, partnumbers)
    related_products = Spree::Product.where(partnumber: partnumbers)
    existing_reliation_partnumbers = base_product.relations.map { |rp| rp.related_to.partnumber }
    if related_products.any?
      related_products.each do |r_product|
        next if existing_reliation_partnumbers.include?(r_product.partnumber)

        relation = base_product.relations.new(relation_type_id: relation_type.id,
                                              related_to_type: r_product.class.name,
                                              related_to_id: r_product.id)
        relation.save
      end
    end
  end

  def save_variant_stock(variant, stocks)
      stocks.each do |admin_name,count_on_hand|
      default_stock_location = Spree::StockLocation.find_by(admin_name: admin_name) || default_stock_location
      return unless default_stock_location

      stock_item = Spree::StockItem.find_or_initialize_by(stock_location_id: default_stock_location.id,
                                                          variant_id: variant.id)
      stock_item.count_on_hand = count_on_hand
      stock_item.save!
    end
  end

  def save_item_attributes(variant, properties)
    product = variant.product
    processed_property_ids = []

    properties.each do |property_name, value|
      property = Spree::Property.find_or_initialize_by(name: property_name, vendor_id: vendor_id)
      unless property.persisted?
        property.presentation = property_name
        property.save
      end

      product_property = Spree::ProductProperty.find_or_initialize_by(property_id: property.id, product_id: product.id)
      product_property.value = value
      product_property.save

      processed_property_ids.push(property.id)
    end

    # Destroy old product properties
    old_product_properties = Spree::ProductProperty.where(product_id: product.id).where.not(property_id: processed_property_ids)
    old_product_properties.destroy_all if old_product_properties.any?
  end

  def send_vendor_notification
    Spree::VendorMailer.send_import_error_notification(ERROR_LOG_FILE, vendor_id).deliver_later
  rescue Exception => e
    Rollbar.critical("Error in sending vendor notification: #{e}")
  end

  def attached_log_file_to_vendor
    file_name = full_spider ? "#{vendor.full_spider}.json" : "#{vendor.quick_spider}.json"

    persisted_log_file = Spree::Vendor.find_by(id: vendor&.id).scrapinghub_error_files.attachments.select {|att| [file_name].include?(att.blob.filename.to_s)}
    if persisted_log_file.any?
      persisted_log_file.each { |f| f.destroy }
    end
    vendor.scrapinghub_error_files.attach(io: File.open(ERROR_LOG_FILE), filename: file_name)
  end

  private
  def save_variants(variant, variants_data)
    variants_data.each do |variant_data|
      local_variant = Spree::Variant.active.find_by(sku: "#{vendor_id}_#{variant_data['sku']}") || Spree::Variant.new(
        sku: variant_data['sku'], product_id: variant.product_id
      )
      local_variant.option_value_ids = get_option_value_ids(variant.product_id, variant_data) if variant_data['size'].present? || variant_data['color'].present? || variant_data['ram'].present? || variant_data['almacenamiento'].present?
      local_variant.name = variant_data['name'] if variant_data['name'].present?
      local_variant.price = variant_data['price'] if variant_data['price'].present?
      local_variant.save!

      # saving image for variant
      %w[image images].each do |data|
        next unless variant_data[data].present?
        @variant_images[local_variant.id.to_s] ? (@variant_images[local_variant.id.to_s] += variant_data[data]) : @variant_images[local_variant.id.to_s] = variant_data[data]
      end
    end
  end

  def all_required_fields_exists?(row_hash)
    fields = %w[sku price]
    fields.push('stock') unless row_hash['variants'].present?
    fields.push('name') if full_spider

    row_hash.values_at(*fields).all?
  end

  def process_image_upload
    UploadVariantImagesJob.perform_later(@variant_images) if @variant_images.any?
  end

  def process_datasheet_upload
    UploadDatasheetFilesJob.perform_later(@datasheet_files) if @datasheet_files.any?
  end

  def save_product_variant_stock(variants_data)
    variants_data.each do |variant_data|
      local_variant = Spree::Variant.active.find_by(sku: "#{vendor_id}_#{variant_data['sku']}")
      next unless local_variant.present?

      save_variant_stock(local_variant,variant_data['stock']) if variant_data['stock'].present?
      local_variant.price = variant_data['price'] if variant_data['price'].present?
      local_variant.save
    end
  end

  def build_variants_data(member)
    row = member.xpath('./value/array/data/value').map do |variant|
      variant.xpath('./struct/member').map do |v|
        if v.at('name').text == 'stock'
          [v.at('name').text,bulid_stock_data(v)]
        elsif %w[images image].include?(v.at('name')&.text)
          [v.at('name').text, bulid_image_data(v)]
        else
          [v.at('name').text, v.at('value').text.strip]
        end
      end.compact.to_h
    end
    row
  end

  def bulid_stock_data(stocks)
    stocks.xpath('./value/struct/member').map { |key| [key.at('name').text, key.at('value').text.strip] }.compact.to_h
  end

  def bulid_image_data(data)
    data.at('value')&.text&.strip.present? ? data.xpath('./value/array/data/value').map { |x| x.text.strip } : []
  end
end
