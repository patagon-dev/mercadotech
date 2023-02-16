# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Banks::RefundMoney do
  let!(:vendor) { create(:vendor_with_bank_transfer) }
  let!(:payment_method) { create(:webpay_payment_method) }
  let!(:payment) { create(:payment, payment_method: payment_method, order: create(:order_ready_to_ship), state: 'completed', vendor: vendor) }
  let!(:reimbursement) { create(:reimbursement) }

  describe 'Bank Refund Money Service' do
    before do
      @reference = [payment, reimbursement].sample
      @amount = @reference == payment ? @reference.amount : @reference.return_items.map { |ri| ri.total.to_d.round(2) }.sum
      @vendor = @reference == payment ? @reference.vendor : @reference.customer_return.vendor
    end

    it 'should return bank account not found response' do
      response = Banks::RefundMoney.new(@reference.number, @amount.abs, @vendor.id).execute

      expect(response[:success]).to eq(false)
      expect(response[:message]).to eq(Spree.t(:not_found, scope: :bank_account))
    end

    # context 'Check Refund Money Service' do
    #   before do
    #     @reference.order.user.bank_accounts = [create(:bank_account)]
    #   end

    #   it 'should return success refund message when vendor has set creds' do
    #     total_refunds = Spree::RefundHistory.count
    #     response = Banks::RefundMoney.new(@reference.number, @amount.abs, @vendor.id).execute

    #     expect(response[:success]).to eq(true)
    #     expect(total_refunds).not_to eq(Spree::RefundHistory.count)
    #   end

    #   it 'should return failure refund message when vendor does not set creds' do
    #     @vendor.update_columns(enable_bank_transfer: false, bank_transfer_url: '', bank_transfer_login: '', bank_transfer_password: '')
    #     total_refunds = Spree::RefundHistory.count
    #     response = Banks::RefundMoney.new(@reference.number, @amount.abs, @vendor.id).execute

    #     expect(response[:success]).to eq(false)
    #     expect(total_refunds).to eq(Spree::RefundHistory.count)
    #   end
    # end
  end
end
