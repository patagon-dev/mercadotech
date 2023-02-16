# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::BankAccount do
  let(:bank_account) { create(:bank_account) }
  let(:user) { create(:user) }

  context 'validations' do
    it 'should validates name, account_number, email, rut' do
      expect(bank_account).to validate_presence_of(:account_number)
      expect(bank_account).to validate_presence_of(:name)
      expect(bank_account).to validate_presence_of(:email)
      expect(bank_account).to validate_presence_of(:rut)
    end

    it 'should validates rut with BankRutValidator' do
      bank_account.rut = '10268889-9'
      bank_account.save

      expect(bank_account.valid?).to eq(true)
      expect(bank_account.rut).to eq(Rut.remove_points('10.268.889-9'))
    end

    it 'should not validates if rut contains dots' do
      bank_account.rut = '10.268.889-9'
      bank_account.save

      expect(bank_account.valid?).to eq(false)
      expect(bank_account.errors.full_messages.join(',')).to eq("Rut #{Spree.t(:invalid_rut)}")
    end
  end

  context 'associations' do
    it { should belong_to(:user).optional }
    it { should belong_to(:bank) }
  end

  context 'callback #after_save' do
    before { bank_account.update(user_id: user.id, is_default: true) }

    it 'should ensure_one_default_per_user' do
      bank_account2 = create(:bank_account)
      bank_account2.update(user_id: user.id, is_default: true)

      expect(bank_account2.is_default).to eq(true)
      expect(bank_account.reload.is_default).to eq(false)
    end
  end
end
