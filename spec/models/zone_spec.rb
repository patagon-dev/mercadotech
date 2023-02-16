# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Zone do
  let(:country) { create(:country) }
  let(:state) { create(:state, country: country) }
  let(:county) { create(:county, state: state) }
  let(:address) { create(:address, state: state, country: country, county: county) }

  context 'associations' do
    it { should have_many(:counties) }
  end

  context 'match zones' do
    before do
      zoneable = [county, country, state].sample
      zone_member = create(:zone_member, zoneable_type: zoneable.class.name, zoneable_id: zoneable.id)
    end
    it 'should returns the matching zone with the highest priority zone type' do
      expect(Spree::Zone.match(address).class.name).to eq('Spree::Zone')
    end
  end

  context 'potential match zones with kind country' do
    let!(:zone) { create(:zone_with_country, kind: 'country') }

    it 'should match zones of the same kind with similar countries' do
      expect(Spree::Zone.potential_matching_zones(zone).first.class.name).to eq('Spree::Zone')
    end
  end

  context 'potential match zones without any kind' do
    before do
      zoneable = [county, country, state].sample
      @zone = create(:zone, zone_members_count: 1, kind: zoneable.class.name.split('::')[1].downcase)
      zone_member = create(:zone_member, zoneable_type: zoneable.class.name, zoneable_id: zoneable.id, zone_id: @zone.id)
    end
    it 'should match zones of the same kind with similar county' do
      expect(Spree::Zone.potential_matching_zones(@zone).first.class.name).to eq('Spree::Zone')
    end
  end
end
