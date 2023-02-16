# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::VendorTag do
  let!(:vendor_tag) { create(:vendor_tag) }

  context 'associations' do
    it { should belong_to(:vendor) }
  end
end
