FactoryBot.modify do
  factory :stock_location, class: Spree::StockLocation do
    vendor_id { Spree::Vendor.first&.id || create(:vendor).id }
    enviame_warehouse_code { 'cod_bod' }
    city { 'Renca' }
    google_place_id { 'ChIJhxVDWxPBYpYRsnqSq9EXzUA' }
    latitude { -0.33395489e2 }
    longitude { -0.70747309e2 }
  end
end
