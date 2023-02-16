# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::StockLocation do
  let(:stock_location) { create(:stock_location) }

  context 'callback #after_save' do
    it 'should ensure one rma default' do
      stock_location2 = create(:stock_location)
      stock_location2.update(rma_default: true)

      expect(stock_location2.rma_default).to eq(true)
      expect(stock_location.reload.rma_default).to eq(false)
    end
  end
end
