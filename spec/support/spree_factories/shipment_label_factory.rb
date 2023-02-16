# frozen_string_literal: true

FactoryBot.define do
  factory :shipment_label, class: Spree::ShipmentLabel do
    tracking_number  { '1234' }
    label_url        { 'label_url/tracking' }
  end
end
