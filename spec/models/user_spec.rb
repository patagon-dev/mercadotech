# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::User do
  let(:user) { create(:user) }
  let!(:order) { create(:order, email: user.email, user_id: nil) }
  let!(:bank_account) { create(:bank_account, user_id: nil, is_guest_user: true, guest_user_email: order.email, email: order.email) }

  context '#validations' do
    it 'should return valid RUT response' do
      user.rut = '16607830-K'
      expect(user.valid?).to eq(true)

      user.rut = '10.268.889-9'
      expect(user.valid?).to eq(true)
    end

    it 'should return invalid RUT response' do
      user.rut = '16607830-S'

      expect(user.valid?).to eq(false)
      expect(user.errors.full_messages.join(',')).to eq("Rut #{Spree.t(:invalid_rut)}")
    end
  end

  describe 'callbacks' do
    context '#before_save' do
      it 'should format RUT' do
        user.rut = '16607830K'
        user.save
        expect(user.rut).to eq(Rut.formatear('16607830K'))
      end
    end

    context '#after_commit on create' do
      before do
        user.update_guest_user_records
      end
      it 'should update guest user records' do
        order = Spree::Order.last
        bank_account = Spree::BankAccount.last

        expect(order.user_id).to eq(user.id)
        expect(bank_account.user_id).to eq(user.id)
        expect(bank_account.is_guest_user).to eq(false)
      end
    end
  end

  context 'associations' do
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:return_authorizations).through(:orders) }
    it { should have_many(:stores).through(:spree_store_admin_users) }
    it { should have_many(:spree_store_admin_users) }
    it { should have_many(:webpay_oneclick_mall_users) }
  end
end
