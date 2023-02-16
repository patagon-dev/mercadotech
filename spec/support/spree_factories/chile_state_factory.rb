# frozen_string_literal: true

FactoryBot.define do
  factory :chile_state, class: Spree::State do
    sequence(:name) { 'RM' }
    sequence(:abbr) { 'RM' }
    country do |country|
      chile = Spree::Country.find_by(numcode: 152)
      chile.present? ? chile : country.association(:country)
    end
  end
end
