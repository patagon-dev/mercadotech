# frozen_string_literal: true

FactoryBot.define do
  factory :store_authentication_type, class: Spree::StoreAuthenticationType do
    store
    authentication_method
  end
end
