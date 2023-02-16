require 'open-uri'

class ProductNotCreatedError < ::StandardError
end

class VariantNotFoundError < ::StandardError
end

class Products::Base
  attr_reader :path, :vendor_id, :vendor, :shipping_category_id, :product_ids, :store_ids

  include ImportUtilBase

  def initialize(path, vendor_id, _spider_id = nil)
    @path = path
    @vendor_id = vendor_id
    @vendor = Spree::Vendor.find(vendor_id)
    @shipping_category_id = (Spree::ShippingCategory.find_by(name: "#{vendor_id}_medium", vendor_id: vendor_id) || Spree::ShippingCategory.create(name: 'medium', vendor_id: vendor_id)).id
    @store_ids = vendor.import_store_ids.map(&:to_i)
    @import_errors = {}
    @product_ids = []
  end

  def import
    process_import
    after_import(product_ids)
  end

  def after_import(product_ids)
    if product_ids.any?
      reset_stock_to_zero
      Spree::Product.where(id: product_ids).map(&:reindex) # reindex products
    end
    File.delete(path)
  end

  def save_variant_stock(variant, stocks)
    stocks.each do |st|
      stock_location = st.split(':')
      stock_item = variant.stock_items.find_or_initialize_by(stock_location_id: stock_location[0])
      stock_item.count_on_hand = stock_location[1]
      stock_item.save!
    end
  end

  def save_gallery_images(variant, images)
    images = images.reject { |e| e.to_s.empty? || URI.parse(e.to_s).host.nil? }
    images.each do |image|
      save_image(variant, image)
    end
  end

  def save_image(variant, image)
    ActiveRecord::Base.transaction do
      image = URI.encode(image)
      filename = image.split('/').last
      tempfile = open(image.strip)
      checksum = Digest::MD5.base64digest(tempfile.read)
      existing_img = variant.images.any? { |img| checksum == img&.attachment&.blob&.checksum }

      unless existing_img.present?
        variant.images.create!(attachment: { io: File.open(tempfile.path), filename: filename })
      end
    rescue Exception => e
      puts "Exception #{e} for #{image.strip} and product - #{variant.product.id}"
    end
  end

  def product_attributes(attributes_hash, prototype = nil, variant = nil)
    attrs = {
      vendor_id: vendor_id,
      shipping_category_id: shipping_category_id,
      available_on: Date.today,
      discontinue_on: nil,
      store_ids: store_ids,
      sku: attributes_hash['sku'],
      price: attributes_hash['price']
    }

    attrs.merge!(partnumber: attributes_hash['partnumber']) if attributes_hash['partnumber'].present?
    attrs.merge!(etilize_id: attributes_hash['etilize_id']) if attributes_hash['etilize_id'].present?
    attrs.merge!(solotodo_id: attributes_hash['solotodo_id']) if attributes_hash['solotodo_id'].present?

    if attributes_hash['name'].present? || attributes_hash['description'].present?
      attrs.merge!(
        name: attributes_hash['name'],
        description: sanitize_description(attributes_hash['description']),
        weight: attributes_hash['weight']&.to_f,
        manufacturer: attributes_hash['manufacturer']
      )
    end

    if prototype && proto_type = Spree::Prototype.find_by(name: prototype)
      attrs[:prototype_id] = proto_type.id
    end

    meta_keywords = [attrs[:partnumber], attrs[:manufacturer]].compact.join(', ')
    attrs.merge!(meta_keywords: meta_keywords) if meta_keywords.present?

    attrs.compact.merge!(discontinue_on: nil)
    attrs
  end

  def sanitize_description(product_description)
    return nil if product_description.blank? || product_description.nil?

    Spree::Config[:show_raw_product_description] ? product_description : product_description.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
  end

  def save_volume_price(variant, prices)
    role_id = Spree::Role.find_by(name: 'user')&.id
    prices.each do |price|
      key_price = price.split('::')
      volume_price = variant.volume_prices.find_or_initialize_by(name: key_price[0], range: key_price[0], discount_type: 'price')
      volume_price.amount = key_price[1].to_f
      volume_price.role_id = role_id if role_id
      volume_price.save!
    end
  end

  def reset_stock_to_zero
    variant_ids = Spree::Product.where(id: product_ids).joins(:variants_including_master).pluck('spree_variants.id')
    remaining_variant_ids = vendor.variant_ids - variant_ids
    ResetStockItemsJob.perform_later(remaining_variant_ids)
  end

  def get_option_value_ids(product_id, variant_data)
    option_value_ids = []

    %w[color size].each do |option_type|
      next unless variant_data[option_type].present?

      ot_record = Spree::OptionType.find_by(name: option_type) || Spree::OptionType.new(name: option_type, presentation: option_type.titleize)
      Spree::ProductOptionType.find_or_create_by(product_id: product_id, option_type_id: ot_record.id)
      option_value = Spree::OptionValue.find_by(name: variant_data[option_type], option_type_id: ot_record.id) || Spree::OptionValue.create(name: variant_data[option_type], presentation: variant_data[option_type], option_type_id: ot_record.id)
      option_value_ids << option_value&.id
    end
    option_value_ids.compact
  end
end
