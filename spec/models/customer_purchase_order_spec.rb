# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::CustomerPurchaseOrder do
  let(:customer_purchase_order) { create(:customer_purchase_order) }

  context 'associations' do
    it 'should belongs to vendor and order' do
      expect(customer_purchase_order).to belong_to(:order).optional
      expect(customer_purchase_order).to belong_to(:vendor).optional
    end

    it 'should has one attachment' do
      expect(customer_purchase_order.purchase_order).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end
