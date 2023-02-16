# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Variant do
  let(:variant) { create(:variant, sku: 'abc') }

  describe 'callbacks' do
    context '#before_save' do
      it 'should prepend vendor id in sku' do
        expect(variant.sku).to eq("#{variant.vendor_id}_abc")
      end
    end

    context '#after_update' do
      it 'should update count on hand to 0 if vendor changed' do
        vendor = create(:vendor, name: 'vendor2')
        variant.update(vendor_id: vendor.id)

        expect(variant.product.in_stock?).to eq(false)
      end
    end
  end
end
