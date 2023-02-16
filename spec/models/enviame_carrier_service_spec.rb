# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::EnviameCarrierService do
  let(:enviame_carrier_service) { create(:enviame_carrier_service) }

  context 'associations' do
    it 'should belongs_to enviame_carrier' do
      expect(enviame_carrier_service).to belong_to(:enviame_carrier)
    end
  end
end
