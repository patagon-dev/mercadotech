# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::PaymentsController, type: :controller do
  let!(:vendor) { create(:vendor_with_bank_transfer) }
  let!(:payment) { create(:payment, order: create(:shipped_order), vendor: vendor) }
  let!(:refund_history) { create(:refund_history, reference_number: payment.number) }
  let!(:admin_user) { create(:admin_user) }
  let!(:bank_account) { create(:bank_account, user_id: payment.order.user.id) }

  describe 'Payment' do
    before(:each) do
      sign_in(admin_user)
    end

    context '#GET refund history' do
      it 'should show refund histories' do
        get :show, params: {
          id: payment.number,
          order_id: payment.order.number
        }

        expect(response).to have_http_status(200)
        expect(assigns(:refund_history)).to be_an_instance_of(Spree::RefundHistory)
      end
    end

    # context '#PUT wire transfer' do
    #   it 'should make refund with wire transfer api' do
    #     put :make_refund, params: {
    #       id: payment.number,
    #       order_id: payment.order.number
    #     }

    #     expect(flash[:success]).to eq(Spree.t(:refund_successfully, scope: :bank_account))
    #     expect(response).to redirect_to(spree.admin_order_payments_path(payment.order))
    #   end
    # end
  end
end
