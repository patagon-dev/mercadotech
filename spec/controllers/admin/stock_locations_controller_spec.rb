# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::StockLocationsController, type: :controller do
  let!(:admin_user) { create(:admin_user) }
  let!(:stock_location) { create(:stock_location_with_items) }

  describe 'Stock Location' do
    before(:each) do
      sign_in(admin_user)
    end

    context 'Get #stock_location_report' do
      it 'should create stock location report' do
        get :stock_location_report, params: {
          'id' => stock_location.id
        }

        expect(response.headers['Content-Type']).to eq('application/xls')
      end
    end
  end
end
