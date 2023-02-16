# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::ReturnAuthorizationsController, type: :controller do
  let!(:admin_user) { create(:admin_user) }
  let!(:vendor) { create(:vendor) }
  let!(:vendor_user) { create(:user, spree_roles: [create(:role, name: 'vendor')], vendors: [vendor]) }
  let!(:return_item) do
    return_item = create(:return_item)
    return_item.return_authorization.update_columns(vendor_id: Spree::Product.last&.vendor_id)
    return_item.reload
  end
  let!(:return_authorization) { return_item.return_authorization.reload }

  describe 'Return Authorization' do
    before(:each) do
      user = [admin_user, vendor_user].sample
      sign_in(user)
    end

    context 'GET #index' do
      it 'should load return authorizations for current vendor or admin user' do
        order = return_authorization.order
        get :index, params: {
          order_id: order.number
        }

        expect(response).to have_http_status(:success)
        expect(assigns(:return_authorizations)).to eq(order.return_authorizations)
      end
    end

    context 'PUT #generate shipping label' do
      before do
        chile_state = create(:state, name: 'RM', abbr: 'RM')
        return_authorization.stock_location.update_column(:state_id, chile_state.id)
        return_authorization.stock_location.reload
      end

      # it 'should generate shipping label' do
      #   order = return_authorization.order

      #   expect do
      #     put :generate_shipping_label, params: {
      #       order_id: order.number,
      #       id: return_authorization.id,
      #       format: 'js'
      #     }
      #   end.to change { Spree::ShipmentLabel.count }.by(1)

      #   expect(response).to redirect_to(spree.admin_order_generate_return_shipping_label_path(order.number, return_authorization.id))
      # end

      it 'should generate pickup request' do
        return_authorization.update_columns(request_pickup: true, pickup_date: (Date.today + 5.days).to_s)
        return_authorization.reload
        order = return_authorization.order

        put :generate_shipping_label, params: {
          order_id: order.number,
          id: return_authorization.id,
          format: 'js'
        }

        expect(response).to redirect_to(spree.admin_order_generate_return_shipping_label_path(order.number, return_authorization.id))
      end
    end

    context 'DESTROY #shipment label' do
      it 'should remove shipment label' do
        shipment_label = create(:shipment_label, return_authorization_id: return_authorization.id)
        return_authorization.reload
        order = return_authorization.order

        expect do
          delete :destroy_label, params: {
            order_id: order.number,
            id: return_authorization.id,
            format: 'js'
          }
        end.to change { Spree::ShipmentLabel.count }.by(-1)

        expect(response).to redirect_to(spree.edit_admin_order_return_authorization_path(order.number, return_authorization.id))
      end
    end
  end
end
