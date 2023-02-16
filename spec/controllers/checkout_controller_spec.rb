# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::CheckoutController, type: :controller do
  let!(:user) { create(:user) }
  let!(:webpay_payment) { create(:webpay_payment_method) }
  let!(:oneclick_webpay_payment) { create(:webpay_oneclick_payment_method) }

  let!(:order) do
    order = create(:order_with_line_items, state: 'payment')
    @vendor = Spree::Vendor.first
    @vendor.update(state: 'active')
    order.update(user_id: user.id, state_lock_version: '2')
    order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, @vendor.id) }
    order.reload
  end

  describe 'Logged in user checkout' do
    before(:each) do
      sign_in user
    end

    context 'PATCH #update' do
      it 'should redirect order to selected webpay payment portal' do
        payment_methods = { "#{webpay_payment.id}": webpay_ws_mall_path({ state: 'webpay_ws_mall' }), "#{oneclick_webpay_payment.id}": 'http://test.host/oneclick_mall/pay' }
        payment_method_id = payment_methods.keys.sample

        patch :update, params: {
          order: {
            state_lock_version: '2', payments_attributes: [{ payment_method_id: payment_method_id }]
          },
          state: 'payment'
        }

        expect(response.body).to include(payment_methods[payment_method_id])
      end
    end

    context 'Restrict checkout when store is on maintenance mode' do
      before do
        order.store.maintenance_mode = true
        order.store.save
      end

      it 'should redirect_to cart path' do
        patch :update, params: {
          order: {
            state_lock_version: '2', payments_attributes: [{ payment_method_id: webpay_payment.id }]
          },
          state: 'payment'
        }

        expect(response).to redirect_to(cart_path)
      end
    end

    context 'Ensure vendor minimum order value' do
      before do
        @vendor.update!(set_minimum_order: true, minimum_order_value: (order.total + 100))
      end

      it 'should redirect to cart path if minimum order value is > order total' do
        get :edit, params: {
          state: 'payment'
        }

        expect(response).to redirect_to(cart_path)
        expect(flash[:error]).to eq(Spree.t(:failed_minimum_order_criteria, name: @vendor.name, amount: @vendor.display_minimum_order_value))
      end
    end

    context 'Remove webay state if invalid payment' do
      before do
        create(:payment, order: order, payment_method: oneclick_webpay_payment, amount: order.total, accepted: true)
        order.next!
        order.reload
      end

      it 'should invalidate old payment of webpay and change order state to payment' do
        get :edit, params: {
          state: order.state
        }

        expect(response).to have_http_status(200)
        expect(order.reload.state).to eq('payment')
      end
    end

    context 'Ensure active vendors in cart' do
      before do
        @vendor.update(state: 'pending')
      end

      it 'should redirect to cart' do
        get :edit, params: { state: 'payment' }

        expect(response).to redirect_to(cart_path)
      end
    end

    context 'Add store credit payments' do
      it 'should create customer purchase order with attachment' do
        expect do
          patch :update, params: {
            order: {
              state_lock_version: '2',
              payment_attributes: [{ payment_method_id: create(:store_credit_payment_method).id }]
            },
            purchase_order: [{
              purchase_order_number: SecureRandom.hex(6),
              purchase_order: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/attachments', 'logo', 'test_email_logo.png')),
              vendor_id: @vendor.id
            }],
            apply_store_credit: '',
            state: 'payment'
          }
        end.to change { order.customer_purchase_orders.count }.by(1)
      end
    end
  end
end
