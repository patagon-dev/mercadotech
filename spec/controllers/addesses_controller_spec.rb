# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::AddressesController, type: :controller do
  let(:user) { create(:user) }
  let(:address) { create(:address, user_id: user.id) }
  let(:valid_attributes) { { firstname: 'Rahul', lastname: 's', address1: '112', address2: '', state_id: '589', country_id: '46', county_id: '315', phone: '1122334455', company_rut: '10.268.889-9', street_number: '23', document_type: '39' } }
  let(:invalid_attributes) { { company_rut: '11.268.889.9.23' } }

  describe 'PATCH #update' do
    before(:each) do
      sign_in user
    end

    it 'should update address with valid attributes and keep user_id' do
      patch :update, params: {
        id: address.id, address: valid_attributes
      }

      expect(response).to have_http_status(:success)
      expect(assigns(:address).user_id).to eq(address.reload.user_id)
    end

    it 'should not update address with invalid attributes' do
      patch :update, params: {
        id: address.id, address: invalid_attributes
      }

      expect(response).to render_template(:edit)
    end
  end
end
