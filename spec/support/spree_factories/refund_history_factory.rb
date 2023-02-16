# frozen_string_literal: true

FactoryBot.define do
  factory :refund_history, class: Spree::RefundHistory do
    vendor_id { Spree::Vendor.first&.id || create(:vendor).id }
    user_id { Spree::User.first&.id || create(:user).id }
    reference_number { 'A1224' }
    amount { '120' }
  end
end
