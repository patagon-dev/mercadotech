FactoryBot.modify do
  factory :base_product, class: Spree::Product do
    vendor { |r| Spree::Vendor.first || r.association(:vendor) }
    partnumber { 'ABCDEFGH' }

    after :create do |product|
      product.master.stock_items.first.adjust_count_on_hand(10)
    end
  end
end
