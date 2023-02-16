FactoryBot.modify do
  factory :shipping_category, class: Spree::ShippingCategory do
    vendor_id { Spree::Vendor.first&.id || create(:vendor).id }
  end
end
