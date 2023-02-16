# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::OneclickMallSubscriptionController, type: :controller do
  let(:user) { create(:user, rut: '') }
  let!(:order) do
    order = create(:order_with_line_items, state: 'payment')
    order.update(user_id: user.id, state_lock_version: '5')
    order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, Spree::Vendor.first&.id) }
    order.reload
  end

  describe 'Webpay Oneclick Subscription' do
    before do
      sign_in(user)
      create(:payment, order: order, payment_method: create(:webpay_oneclick_payment_method), amount: order.total, accepted: true)
      order.next!
      order.reload
    end

    # context 'GET #subscribe' do
    #   it 'should subscribe user and make rut non empty' do
    #     expect do
    #       post :subscribe
    #     end.to change { user.webpay_oneclick_mall_users.count }.by(1)

    #     expect(user.reload.rut).not_to be_empty
    #   end
    # end

    context 'GET #subscribe_confirmation' do
      before do
        @oneclick_user = create(:oneclick_user, user: user)
      end

      it 'should redirec to failure path if subscription not confirm' do
        post :subscribe_confirmation, params: {
          TBK_TOKEN: @oneclick_user.token
        }

        expect(response).to redirect_to(oneclick_mall_subscribe_failure_path)
      end
    end

    context 'DELETE #unsubscribe' do
      before do
        @oneclick_user = create(:oneclick_user, user: user)
      end

      it 'should redirect to failure path if not unsubscribed' do
        delete :unsubscribe, params: {
          oneclick_user_id: @oneclick_user.id
        }

        expect(response).to redirect_to(checkout_path)
      end
    end
  end
end
