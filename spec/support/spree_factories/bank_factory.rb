# frozen_string_literal: true

FactoryBot.define do
  factory :bank, class: Spree::Bank do
    name { 'BANCO SANTANDER' }
    code          { '0000' }
  end
end
