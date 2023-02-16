# frozen_string_literal: true

FactoryBot.define do
  factory :county, class: Spree::County do
    name { 'Huechuraba' }
    state_id { Spree::State.first&.id || create(:state).id }
  end
end
