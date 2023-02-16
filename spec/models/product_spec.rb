# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Product do
  let(:product) { create(:product) }
  let(:variant1) { create(:variant, product: product) }
  let(:variant2) { create(:variant, product: product) }

  describe 'callbacks' do
    context '#after_update set_vendor' do
      it 'should update vendor id to all product variants' do
        expect(product.variants_including_master.pluck(:vendor_id).uniq).to contain_exactly(product.vendor_id)
      end
    end

    context '#after_commit reindex product' do
      before do
        allow(product).to receive(:reindex)
      end

      it 'should reindex product' do
        expect(product).to receive(:reindex)

        product.updated_at = Time.zone.now
        # product.bulk_index = false
        product.save
      end
    end
  end

  it 'should return vendor status' do
    expect(product.has_active_vendor?).to eq(product.vendor&.is_active?)
  end

  it 'should include taxons in ransack attributes' do
    expect(Spree::Product.whitelisted_ransackable_attributes).to include('partnumber')
  end

  it 'should include taxons in ransack associations' do
    expect(Spree::Product.whitelisted_ransackable_associations).to include('taxons')
  end
end
