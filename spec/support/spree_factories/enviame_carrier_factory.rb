# frozen_string_literal: true

FactoryBot.define do
  factory :enviame_carrier, class: Spree::EnviameCarrier do
    name { 'STARKEN' }
    code { 'SKN' }
    country { 'CL' }
  end
end
