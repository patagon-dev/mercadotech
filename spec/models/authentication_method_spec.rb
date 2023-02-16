# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::AuthenticationMethod do
  let(:store_authentication_type) { create(:store_authentication_type) }

  context 'associations' do
    it { should have_many(:store_authentication_types) }
    it { should have_many(:stores).through(:store_authentication_types) }
  end
end
