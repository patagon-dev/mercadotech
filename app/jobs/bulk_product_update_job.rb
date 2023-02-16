class BulkProductUpdateJob < ApplicationJob
  queue_as :others

  def perform(product_ids, selected_option_id, type)
    case type
    when 'shipping_category'
      bulk_update_shipping_category(product_ids, selected_option_id)
    when 'enable_disable_product'
      bulk_enable_disable_products(product_ids, selected_option_id)
    end
  end

  def bulk_update_shipping_category(ids, shipping_category_id)
    vendor_id = Spree::ShippingCategory.find_by(id: shipping_category_id)&.vendor_id
    vendors_products = Spree::Product.where(id: ids, vendor_id: vendor_id)

    if vendors_products.present?
      vendors_products.each do |product|
        ApplicationRecord.transaction do
          product.update(shipping_category_id: shipping_category_id)
        end
      end
    end
  rescue Exception => e
    puts e
  end

  def bulk_enable_disable_products(ids, type)
    selected_option = type == '0' ? Date.today : nil
    begin
      Spree::Product.where(id: ids).update(discontinue_on: selected_option)
      products = Spree::Product.where(id: ids)

      products.each do |product|
        ApplicationRecord.transaction do
          product.update(discontinue_on: selected_option)
        end
      end
    rescue Exception => e
      puts e
    end
  end
end
