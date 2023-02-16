# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::StockMovement do
  let(:product) { create(:product) }

  context 'By Pass Stock' do
    before do
      @st_item = product.stock_items.first
      @previous_st_count = @st_item.count_on_hand
      product.master.update_column(:by_pass_stock, true)
      stock_movement = create(:stock_movement, stock_item: @st_item)
    end

    it 'should not update stock items if product by pass' do
      expect(@previous_st_count).to eq(@st_item.count_on_hand)
    end
  end
end
