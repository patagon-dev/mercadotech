# frozen_string_literal: true

FactoryBot.define do
  factory :enviame_carrier_service, class: Spree::EnviameCarrierService do
    name { 'Straken' }
    code { 'SKN' }
    description { 'Starken' }
    default     { false }
    enviame_carrier
  end
end
