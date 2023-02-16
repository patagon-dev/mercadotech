# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Ability do
  let(:user) { create(:user) }
  subject(:ability) { Spree::Ability.new(user) }

  context 'Registered abilities' do
    it 'should include vendor and store admin abilities' do
      expect(ability.send(:abilities_to_register)).to include(Spree::StoreAdminAbility, Spree::VendorAbility)
    end
  end
end
