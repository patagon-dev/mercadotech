# frozen_string_literal: true

FactoryBot.define do
  factory :customer_purchase_order, class: Spree::CustomerPurchaseOrder do
    purchase_order_number { '12345' }
    vendor
    order
  end
end
