# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::ShipmentLabel do
  let!(:shipment_label) { create(:shipment_label) }

  context '#associations and #validations' do
    # belongs to associations
    it { expect(shipment_label).to belong_to(:shipment).optional }
    it { expect(shipment_label).to belong_to(:return_authorization).optional }

    it 'should have one attachment' do
      expect(shipment_label.enviame_label).to be_an_instance_of(ActiveStorage::Attached::One)
    end

    # validations
    it { expect(shipment_label).to validate_presence_of(:label_url) }
    it { expect(shipment_label).to validate_presence_of(:tracking_number) }
  end
end
