# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_method, class: Spree::AuthenticationMethod do
    environment { 'test' }
    provider    { 'test' }
    api_key     { 'not in use' }
    api_secret  { 'not in use' }
    active      { true }
  end
end
