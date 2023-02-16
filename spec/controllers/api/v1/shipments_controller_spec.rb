# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'
require 'rspec/active_model/mocks'

RSpec.describe Spree::Api::V1::ShipmentsController, type: :controller do
  let(:shipment) { create(:shipment, state: 'ready') }

  describe 'ShipmentsAPIContoller' do
    before do
      current_api_user.generate_spree_api_key!
      current_api_user.spree_roles << create(:role, name: 'admin')
      stub_authentication!
    end

    it 'should update shipment state' do
      shipment_state = %w[ship pick pack wait alert cancel].sample
      put :update_state, params: {
        shipment: {
          state: shipment_state
        },
        id: shipment.number,
        token: current_api_user.spree_api_key,
        format: 'json'
      }

      expect(response).to have_http_status(200)
      expect(response).to render_template(:show)
    end
  end
end
