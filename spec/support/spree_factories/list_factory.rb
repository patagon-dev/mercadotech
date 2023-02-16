# frozen_string_literal: true

FactoryBot.define do
  factory :list, class: Spree::List do
    key { 'test' }
    name { 'test_name' }
    store_id { Spree::Store.first&.id || create(:store).id }
    default_list { true }
  end
end
