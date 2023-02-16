# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Payment do
  let(:payment) { create(:payment) }

  context 'state_machine' do
    it 'should include custom states in payment' do
      expect(Spree::Payment.state_machines[:state].states.map(&:name)).to include(:refund_pending, :refunded)
    end

    it 'should change state to refund_pending' do
      valid_state = %w[pending processing completed checkout].sample
      payment.state = valid_state
      payment.save
      payment.refund_pending

      expect(payment.reload.state).to eq('refund_pending')
    end

    it 'should mark payment as refunded from refund_pending' do
      payment.state = 'refund_pending'
      payment.save

      payment.refunded
      expect(payment.reload.state).to eq('refunded')
    end
  end

  context 'instance methods' do
    before do
      payment.payment_method = create(:webpay_payment_method)
      payment.save
    end

    it 'should check webpay payment method' do
      expect(payment.webpay_ws_mall?).to eq(true)
    end

    it 'should skip invalidating payments' do
      payment.payment_method = create(%i[webpay_payment_method webpay_oneclick_payment_method].sample)
      payment.save
      expect(payment.state).not_to eq('invalid')
    end

    it 'should check oneclick_mall payment method' do
      payment.payment_method = create(:webpay_oneclick_payment_method)
      payment.save
      expect(payment.oneclick_mall?).to eq(true)
    end
  end

  context 'Bank transfer eligiblity' do
    before do
      @bank_account = create(:bank_account)
      user = create(:user)
      @bank_account.update_columns(user_id: user.id, is_default: true)
      @vendor = create(:vendor, bank_transfer_url: '/test')
      payment.update_columns(vendor_id: @vendor.id, order_id: create(:order, user_id: user.id).id)
    end

    it 'should be able to make bank refund if bank and vendor details exists' do
      expect(payment.eligible_for_api_refund?).to eq(true)
    end

    it 'should not show api refund if vendor has not enable option' do
      @vendor.bank_transfer_url = nil
      @vendor.save
      expect(payment.reload.eligible_for_api_refund?).not_to eq(true)
    end

    it 'should not show api refund if no default bank account' do
      @bank_account.user_id = nil
      @bank_account.save
      expect(payment.eligible_for_api_refund?).to eq(false)
    end
  end
end
