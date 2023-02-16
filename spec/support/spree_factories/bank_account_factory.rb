# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account, class: Spree::BankAccount do
    user
    bank
    account_number { '61205691' }
    name           { 'John smith' }
    rut            { '102688899' }
    email          { user.email }
    is_default     { true }
    is_guest_user  { false }
  end
end
