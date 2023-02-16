# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Enviame::Delivery do
  let!(:order) { create(:order_ready_to_ship) }
  let!(:enviame_carrier) { create(:enviame_carrier, name: 'CHILEXPRESS', code: 'CHX') }
  let!(:enviame_carrier_service) { create(:enviame_carrier_service, enviame_carrier: enviame_carrier) }

  describe 'Enviame Delivery service' do
    context 'When package is single' do
      before do
        @shipment = order.shipments.first
        @shipment.update_column(:n_packages, '1')
        @shipment.reload
      end

      # it 'should generate shipping label when enviame vendor is present' do
      #   expect do
      #     @response = Enviame::Delivery.new(@shipment.number).create
      #   end.to change {Spree::ShipmentLabel.count}.by(1)

      #   expect(@response[:success]).to eq(true)
      # end

      it 'should not generate shipping label when enviame vendor id not present' do
        @shipment.stock_location.vendor.enviame_vendor_id = ''
        @shipment.stock_location.vendor.save
        @shipment.stock_location.vendor.reload

        expect do
          @response = Enviame::Delivery.new(@shipment.number).create
        end.to change {Spree::ShipmentLabel.count}.by(0)

        expect(@response[:success]).to eq(false)
      end
    end

    context 'When package is multiple' do
      before do
        @shipment = order.shipments.first
        @shipment.update_columns(n_packages: 2, enviame_carrier_id: enviame_carrier.id)
        @shipment.reload
      end

      # it 'should generate shipping label when enviame vendor is present' do
      #   expect do
      #     @response = Enviame::Delivery.new(@shipment.number).create
      #   end.to change {Spree::ShipmentLabel.count}.by(2)

      #   expect(@response[:success]).to eq(true)
      # end

      it 'should not generate shipping label when enviame vendor id not present' do
        @shipment.stock_location.vendor.enviame_vendor_id = ''
        @shipment.stock_location.vendor.save
        @shipment.stock_location.vendor.reload

        expect do
          @response = Enviame::Delivery.new(@shipment.number).create
        end.to change {Spree::ShipmentLabel.count}.by(0)

        expect(@response[:success]).to eq(false)
      end
    end
  end
end
