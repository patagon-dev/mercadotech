# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::OneclickMallPaymentController, type: :controller do
  let(:user) { create(:user) }
  let!(:order) do
    order = create(:order_with_line_items, state: 'payment')
    order.update(user_id: user.id, state_lock_version: '5')
    order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, Spree::Vendor.first&.id) }
    order.reload
  end

  describe 'Webpay Oneclick Mall' do
    before do
      sign_in(user)
      create(:payment, order: order, payment_method: create(:webpay_oneclick_payment_method), amount: order.total, accepted: true)
      order.next!
      order.reload
    end

    context 'GET #pay' do
      it 'should redirect to webpay subscription path if not registered or subscribed' do
        get :pay

        expect(response).to redirect_to(oneclick_mall_subscription_path)
      end

      it 'should redirect to failure path if payment failed' do
        oneclick_user = create(:oneclick_user, user: user)
        share_no = rand(1..5).to_s

        get :pay, params: {
          oneclick_user_id: oneclick_user.id,
          shares_number: share_no
        }

        expect(response).to redirect_to(oneclick_mall_failure_path({ order_number: order.number }))
      end
    end

    context 'GET #failure' do
      before { @previous_state = order.state }
      it 'should update order state to payment state' do
        get :failure

        expect(@previous_state).not_to eq(order.reload.state)
        expect(order.reload.state).to eq('payment')
      end
    end
  end
end
