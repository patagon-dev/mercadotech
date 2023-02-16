# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::ShippingCategory do
  let(:shipping_category) { create(:shipping_category, name: 'abc') }

  context 'validations' do
    let!(:shipping_category_new) { create(:shipping_category) }

    it { expect(shipping_category).to validate_presence_of(:name) }
    it { expect(shipping_category).to validate_presence_of(:vendor_id) }

    it 'should not have same name for new shipping category' do
      shipping_category_new.update(name: shipping_category.name.split('_', 2)[1])

      expect(shipping_category_new.valid?).to eq(false)
      expect(shipping_category_new.errors.full_messages.join(',')).to eq("Name #{Spree.t(:already_in_use)}")
    end
  end

  context '#callbacks before_save' do
    it 'should prepend vendor id before name' do
      expect(shipping_category.name).to eq("#{shipping_category.vendor_id}_abc")
    end
  end
end
