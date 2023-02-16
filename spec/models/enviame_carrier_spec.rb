# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::EnviameCarrier do
  let(:vendor) { create(:vendor) }
  let(:enviame_carrier) { create(:enviame_carrier) }

  context 'associations' do
    it 'should have many to enviame_carrier_services' do
      expect(enviame_carrier).to have_many(:enviame_carrier_services)
    end

    it 'should has and belongs to many vendors' do
      expect(enviame_carrier).to have_and_belong_to_many(:vendors)
    end
  end
end
