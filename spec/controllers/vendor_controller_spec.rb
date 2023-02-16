# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::VendorsController, type: :controller do
  let(:vendor) { create(:vendor) }

  it 'should show vendor details' do
    get :show, params: {
      id: vendor.id
    }

    expect(response).to have_http_status(200)
    expect(assigns(:vendor)).to be_an_instance_of(Spree::Vendor)
  end
end
