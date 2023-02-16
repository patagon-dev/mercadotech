class Products::XmlImporter < Products::Base
  ITEM_ATTRIBUTES = %w[sku partnumber name weight price volume_price stock image prototype gallery description item_attributes].freeze
  ERROR_LOG_FILE = "ProductXMLImportLog-#{Time.current}__.json".freeze

  def process_import
    doc = Nokogiri::XML(File.open(path))
    items = doc.xpath('//item')

    items.each do |item|
      row_hash = {}

      ITEM_ATTRIBUTES.each do |item_key|
        attribute = item.at(item_key)

        if attribute
          if item_key != 'item_attributes'
            row_hash[item_key] = %w[stock gallery volume_price].include?(item_key) ? attribute.content.tr(" ,\;\n", ',').split(',') : attribute.content
          else
            property_hash = {}
            item.at('item_attributes').elements.each do |element|
              property_hash[element.name] = element.content
            end
            row_hash[item_key] = property_hash
          end
        end
      end

      formatted_sku = row_hash['sku']

      begin
        ::ActiveRecord::Base.transaction do
          # validate all required fields
          all_required_field_present = row_hash.values_at('sku', 'partnumber', 'name', 'weight', 'price', 'stock', 'image', 'prototype', 'description').all?
          next unless all_required_field_present

          # vendor id prefix with sku
          formatted_sku = "#{vendor_id}_#{row_hash['sku']}"
          variant = Spree::Variant.where(sku: formatted_sku, is_master: true).first

          if variant.present?
            attributes = product_attributes(row_hash)
            product = variant.product

            Searchkick.callbacks(false) do
              product.update!(attributes)
            end
            variant.volume_prices.destroy_all
          else
            attributes = product_attributes(row_hash, row_hash['prototype'])
            product = Spree::Product.new(attributes)

            Searchkick.callbacks(false) do
              raise ProductNotCreatedError unless product.save
            end
            variant = product.master
          end

          save_variant_stock(variant, row_hash['stock']) if row_hash['stock'].present? # save stock for stock locations
          save_image(variant, row_hash['image']) if row_hash['image'].present? # save image
          save_gallery_images(variant, row_hash['gallery']) if row_hash['gallery'].present? # save gallery images
          if row_hash['volume_price'].present?
            save_volume_price(variant, row_hash['volume_price'])
          end # save volume prices
          if row_hash['item_attributes'].present?
            save_item_attributes(variant, row_hash['item_attributes'], row_hash['prototype'])
          end # save item attributes
          @product_ids.push(product.id)
        end
      rescue ProductNotCreatedError => e
        data = { partnumber: row_hash['partnumber'], sku: formatted_sku, message: e.message }
        log_data(:product_not_created, data)
      rescue ActiveRecord::RecordInvalid => e
        data = { partnumber: row_hash['partnumber'], sku: formatted_sku, message: e.message }
        log_data(:record_invalid, data)
      rescue Exception => e
        data = { partnumber: row_hash['partnumber'], sku: formatted_sku, message: e.message }
        log_data(:general, data)
      end
    end

    vendor.update_column(:products_xml_imported_at, Time.now)
    write_log_file
  end

  def save_item_attributes(variant, properties, prototype)
    product = variant.product
    proto_type = Spree::Prototype.find_by(name: prototype)
    processed_property_ids = []

    properties.each do |property_name, value|
      property = Spree::Property.find_or_initialize_by(name: property_name, vendor_id: vendor_id)
      unless property.persisted?
        property.presentation = property_name
        property.save
      end

      if proto_type && !proto_type.properties.include?(property)
        proto_type.properties << property
      end # Adding property to prototype

      product_property = product.product_properties.find_or_initialize_by(property_id: property.id)
      product_property.value = value
      product_property.save

      processed_property_ids.push(property.id)
    end

    # Destroy old product properties
    old_product_properties = product.product_properties.where.not(property_id: processed_property_ids)
    old_product_properties.destroy_all if old_product_properties.any?
  end
end
