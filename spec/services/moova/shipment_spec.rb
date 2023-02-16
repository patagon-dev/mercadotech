# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Moova::Shipment do
  let!(:vendor) { create(:vendor_with_moova) }
  let!(:order) { create(:order_ready_to_ship) }

  describe 'Moova Shipment service' do
    context 'Create Moova shipment label' do
      before do
        @shipment = order.shipments.first
      end

      # commented for budget error in google api for moova dev environment
      # it 'should generate shipping label when creds are present in stock location' do
      #   response = Moova::Shipment.new(@shipment.number).create
      #   expect do
      #     @response = Moova::Shipment.new(@shipment.number).create
      #   end.to change {Spree::ShipmentLabel.count}.by(1)

      #   expect(@response[:success]).to eq(true)
      # end

      it 'should not generate shipping label when creds are not present in stock location' do
        @shipment.stock_location.update_columns(latitude: '', longitude: '', google_place_id: '')
        @shipment.reload

        expect do
          @response = Moova::Shipment.new(@shipment.number).create
        end.to change {Spree::ShipmentLabel.count}.by(0)

        expect(@response[:success]).to eq(false)
      end
    end
  end
end
