# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Bank do
  let(:bank) { create(:bank) }

  context 'validations' do
    it 'should validates name and code of bank' do
      expect(bank).to validate_presence_of(:name)
      expect(bank).to validate_presence_of(:code)
    end
  end
end
