# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::AppConfiguration do
  subject(:preferences) { Rails.application.config.spree.preferences }

  context 'Custom Preferences' do
    it 'should have registerable as preference' do
      expect(preferences.has_preference?(:registerable)).to eq(true)
    end

    it 'should have default value #true' do
      expect(preferences&.registerable).to eq(true)
    end
  end
end
