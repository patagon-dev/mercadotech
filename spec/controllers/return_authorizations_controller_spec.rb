# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::ReturnAuthorizationsController, type: :controller do
  let(:user) { create(:user) }
  let!(:order) { create(:shipped_order) }

  describe 'Frontend Return Authorization' do
    before do
      sign_in(user)
      order.update_column(:user_id, user.id)
      order.shipments.map(&:stock_location).uniq.each { |st| st.update(rma_default: true) }
    end

    context 'GET #new' do
      it 'should return authorization instance' do
        get :new, params: {
          order_id: order.number
        }

        expect(response).to have_http_status('200')
        expect(assigns(:return_authorization)).to be_a_new(Spree::ReturnAuthorization)
      end
    end

    context 'POST #create' do
      it 'should create vendor specfic return authorization' do
        post :create, params: {
          return_authorization: {
            return_items_attributes: {
              '0' => {
                inventory_unit_id: order.shipments.take.inventory_unit_ids.sample, return_quantity: '1', pre_tax_amount: '23', exchange_variant_id: '', _destroy: '0'
              }
            },
            request_pickup: '0', return_authorization_reason_id: create(:return_authorization_reason).id, memo: 'dummy'
          },
          order_id: order.number
        }

        expect(response).to redirect_to(account_path)
        expect(flash[:success]).to eq(Spree.t(:successfully_created, resource: 'Item return'))
        expect(order.get_vendors.pluck(:id)).to include(Spree::ReturnAuthorization.last.vendor_id)
      end
    end
  end

  it 'should redirect to unauthorized_access if no user sign_in' do
    get :new, params: {
      order_id: order.number
    }

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(login_path)
  end
end
