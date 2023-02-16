# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Enviame::Pickup do
  let(:return_item) do
    return_item = create(:return_item)
    return_item.return_authorization.update_columns(vendor_id: Spree::Product.last&.vendor_id)
    return_item.reload
  end
  let(:return_authorization) { return_item.return_authorization.reload }

  describe 'Enviame Pickup service' do
    # it 'should return success response for pickup when enviame vendor is present' do
    #   response = Enviame::Pickup.new(return_authorization.number).create

    #   expect(response[:success]).to eq(true)
    # end

    it 'should return false response for pickup when enviame vendor is not present' do
      return_authorization.vendor.update_column(:enviame_vendor_id, '')
      return_authorization.vendor.reload

      response = Enviame::Pickup.new(return_authorization.number).create
      expect(response[:success]).to eq(false)
    end
  end
end
