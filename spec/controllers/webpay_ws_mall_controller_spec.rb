# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::WebpayWsMallController, type: :controller do
  let(:user) { create(:user) }
  let!(:order) do
    order = create(:order_with_line_items, state: 'payment')
    order.update(user_id: user.id, state_lock_version: '5')
    order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, Spree::Vendor.first&.id) }
    order.reload
  end

  describe 'Webpay Normal' do
    before do
      sign_in(user)
    end

    context 'GET #pay' do
      it 'should redirect to failure path if no payment' do
        get :pay

        expect(response).to redirect_to(webpay_ws_mall_failure_path(order_number: order.number))
      end

      it 'should redirect to failure path if no response' do
        create(:payment, order: order, payment_method: create(:webpay_payment_method), amount: order.total, accepted: true)

        get :pay, params: {
          order_number: order.number
        }

        expect(response).to redirect_to(webpay_ws_mall_failure_path(order_number: order.number))
      end
    end

    context 'GET #confirmation' do
      it 'should redirect to order confirmation page if order is complete' do
        create(:payment, order: order, payment_method: create(:check_payment_method), amount: order.total, accepted: true)
        order.next!

        get :confirmation, params: {
          order_number: order.number
        }

        expect(response).to redirect_to(spree.order_path(order.reload))
      end
    end

    context 'GET #success' do
      it 'should redirect to order completion route' do
        create(:payment, order: order, payment_method: create(:check_payment_method), amount: order.total, accepted: true)
        order.next!

        get :success, params: {
          order_number: order.number
        }

        expect(response).to redirect_to(spree.order_path(order.reload))
        expect(flash[:notice]).to eq(Spree.t(:order_processed_successfully))
      end

      it 'should redirect to failure if order not complete' do
        get :success, params: {
          order_number: order.number
        }

        expect(response).to redirect_to(webpay_ws_mall_failure_path(order_number: order.number))
      end
    end
  end
end
