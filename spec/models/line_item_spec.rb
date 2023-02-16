# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::LineItem do
  let(:line_item) { create(:line_item) }

  describe '#custom_copy_price' do
    context 'price or quantity not changed' do
      it 'should not expect any change in price and quantity' do
        expect(line_item.price_changed?).to eq(false)
        expect(line_item.quantity_changed?).to eq(false)
      end

      it 'should set variant price if custom price is null' do
        expect(line_item.custom_price).to eq(nil)
        expect(line_item.price).to eq(line_item.variant.price)
      end

      it 'should set custome price if it is present' do
        line_item.custom_price = rand(10..100)
        line_item.save
        expect(line_item.price).to eq(line_item.custom_price)
      end
    end

    context 'price or quantity changed' do
      it 'should set variant price as line item price if no volumne price and custom price' do
        vprice = line_item.variant.volume_price(line_item.quantity, line_item.order.user)
        expect(vprice).to eq(line_item.variant.price)
        expect(line_item.custom_price).to eq(nil)
      end

      it 'should set custom price as line item price if no volumne price but has custom price' do
        line_item.custom_price = rand(10..100)
        line_item.save
        expect(line_item.price).to eq(line_item.custom_price)
      end

      it 'should set volumne price if volumne price greater then variant price and no custom price' do
        line_item.variant.volume_prices << Spree::VolumePrice.create(variant: line_item.variant, amount: rand(10..100), discount_type: 'percent', range: '(1..2)')
        line_item.custom_price = nil
        line_item.price = rand(10..100) # in order to make sure, price changed
        line_item.save

        expect(line_item.price).to eq(line_item.variant.volume_price(line_item.quantity, nil))
      end
    end
  end
end
