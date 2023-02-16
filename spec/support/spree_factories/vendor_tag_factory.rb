# frozen_string_literal: true

FactoryBot.define do
  factory :vendor_tag, class: Spree::VendorTag do
    text { 'test_tag' }
    color { '#47a3e8' }
    vendor_id { Spree::Vendor.first&.id || create(:vendor).id }
  end
end
