# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::StoreAdminUser do
  let!(:store_admin_user) { create(:store_admin_user) }

  context 'associations and validations' do
    it { should belong_to(:store) }
    it { should belong_to(:user) }

    it 'should validate uniqueness of store id' do
      is_expected.to validate_uniqueness_of(:store_id).scoped_to(:user_id)
    end
  end
end
