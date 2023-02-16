module Spree::VariantPresenterDecorator

  def self.prepended(base)
    base.include ApplicationHelper
  end

  def call
    @variants.map do |variant|
      {
        display_price: display_price(variant),
        price: variant.price_in(current_currency),
        display_compare_at_price: display_compare_at_price(variant),
        should_display_compare_at_price: should_display_compare_at_price?(variant),
        is_product_available_in_currency: @is_product_available_in_currency,
        backorderable: backorderable?(variant),
        in_stock: in_stock?(variant),
        images: images(variant),
        option_values: option_values(variant),
        stock_data: stock_data(variant)
      }.merge(
        variant_attributes(variant)
      )
    end
  end

  def stock_data(variant)
    valid_stock_ids = variant.vendor.stock_locations.pluck(:id)

    stock_hash = variant.stock_items.where(stock_location_id: valid_stock_ids).flat_map { |item| ["stock_name" => item.stock_location.name, "count_on_hand" => item.count_on_hand] }
    stock_hash
  end

  def images(variant)
    variant.images.map do |image|
      {
        alt: image.alt,
        url_product: s3_persisted_url(image.url(:product))
      }
    end
  end

  private

  def variant_attributes(variant)
    {
      id: variant.id,
      sku: variant.sku.split('_', 2)[1],
      name: variant.name,
      purchasable: variant.purchasable?
    }
  end

  Spree::VariantPresenter.prepend self
end
