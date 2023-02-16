# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::StoreAuthenticationType do
  let(:store_authentication_type) { create(:store_authentication_type) }

  context 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:authentication_method) }
  end
end
