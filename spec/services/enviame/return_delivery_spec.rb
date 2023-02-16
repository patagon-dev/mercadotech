# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Enviame::ReturnDelivery do
  let(:return_item) do
    return_item = create(:return_item)
    return_item.return_authorization.update_columns(vendor_id: Spree::Product.last&.vendor_id)
    return_item.reload
  end
  let(:return_authorization) { return_item.return_authorization.reload }

  describe 'Enviame Return Delivery service' do
    before do
      chile_state = create(:state, name: 'RM', abbr: 'RM')
      return_authorization.stock_location.update_column(:state_id, chile_state.id)
      return_authorization.stock_location.reload
    end

    # it 'should generate return delivery label' do
    #   expect do
    #     @response = Enviame::ReturnDelivery.new(return_authorization.number).create
    #   end.to change {Spree::ShipmentLabel.count}.by(1)

    #   expect(@response[:success]).to eq(true)
    # end

    it 'should not generate delivery label' do
      return_authorization.vendor.update_column(:enviame_vendor_id, '')
      return_authorization.vendor.reload

      expect do
        @response = Enviame::ReturnDelivery.new(return_authorization.number).create
      end.to change {Spree::ShipmentLabel.count}.by(0)

      expect(@response[:success]).to eq(false)
    end
  end
end
