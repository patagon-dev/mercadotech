# frozen_string_literal: true

FactoryBot.define do
  factory :store_admin_user, class: Spree::StoreAdminUser do
    store
    user
  end
end
