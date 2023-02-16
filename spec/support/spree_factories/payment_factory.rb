FactoryBot.modify do
  factory :payment, class: Spree::Payment do
    vendor_id { Spree::Vendor.first&.id || create(:vendor).id }
  end
end
