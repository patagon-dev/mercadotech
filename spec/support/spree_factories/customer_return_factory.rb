FactoryBot.modify do
  factory :customer_return, class: Spree::CustomerReturn do
    vendor { |r| Spree::Vendor.first || r.association(:vendor) }
  end
end
