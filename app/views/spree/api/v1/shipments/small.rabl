object @shipment
cache [I18n.locale, 'small_shipment', root_object]

attributes *shipment_attributes
node(:order_id) { |shipment| shipment.order.number }
node(:stock_location_id) { |shipment| shipment.stock_location.id }
node(:stock_location_name) { |shipment| shipment.stock_location.name }
node(:stock_location_admin_name) { |shipment| shipment.stock_location.admin_name }
node(:vendor_id) { |shipment| shipment.stock_location&.vendor_id }
node(:vendor_type) { |shipment| shipment.stock_location&.vendor.vendor_type }

child shipping_rates: :shipping_rates do
  extends 'spree/api/v1/shipping_rates/show'
end

child selected_shipping_rate: :selected_shipping_rate do
  extends 'spree/api/v1/shipping_rates/show'
end

child shipping_methods: :shipping_methods do
  attributes :id, :code, :name
  child zones: :zones do
    attributes :id, :name, :description
  end

  child shipping_categories: :shipping_categories do
    attributes :id, :name
  end
end

child manifest: :manifest do
  glue(:variant) do
    attribute id: :variant_id
  end
  node(:quantity, &:quantity)
  node(:states, &:states)
end

child adjustments: :adjustments do
  extends 'spree/api/v1/adjustments/show'
end
