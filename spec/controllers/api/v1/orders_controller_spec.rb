# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'
require 'rspec/active_model/mocks'

RSpec.describe Spree::Api::V1::OrdersController, type: :controller do
  let(:order) { create(:order) }

  describe 'OrdersAPIContoller' do
    before do
      current_api_user.generate_spree_api_key!
      current_api_user.spree_roles << create(:role, name: 'admin')
      stub_authentication!
    end

    it 'should update order reference numbers' do
      put :update_reference_numbers, params: {
        order: {
          reference_order_numbers: '123455'
        },
        id: order.number,
        token: current_api_user.spree_api_key,
        format: 'json'
      }

      expect(response).to have_http_status(200)
      expect(response).to render_template(:order_reference_numbers)
    end

    it 'should not update order reference numbers' do
      put :update_reference_numbers, params: {
        order: {
          reference_order_numbers: '123455'
        },
        id: '123', # returns 404 error for invalid resource
        token: current_api_user.spree_api_key,
        format: 'json'
      }

      expect(response).to have_http_status(404)
    end
  end
end
