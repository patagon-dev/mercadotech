# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::PaymentMethod do
  pay_methods = %i[check store_credit webpay webpay_oneclick].sample
  let(:payment_method) { create("#{pay_methods}_payment_method".to_sym) }
  let(:store) { create(:store) }

  context 'availability for store' do
    it 'should available_for_store? when store is blank' do
      expect(payment_method.available_for_store?(nil)).to eq(true)
    end

    it 'should available_for_store? when no store payment method exists' do
      expect(payment_method.stores).to match_array([])
      expect(payment_method.available_for_store?(store)).to eq(true)
    end

    it 'should available_for_store? when it includes in store payment methods' do
      payment_method.stores << store
      payment_method.save
      expect(payment_method.available_for_store?(store)).to eq(true)
    end

    it 'should available_for_store? when it belongs to same store' do
      payment_method.store_ids = [store.id]
      payment_method.save
      expect(payment_method.available_for_store?(store)).to eq(true)
    end

    it 'should not available_for_store? when it not include in store payment methods' do
      store2 = create(:store)
      payment_method.stores << store2
      expect(payment_method.available_for_store?(store)).to eq(false)
    end

    it 'should not be available_for_store? when it not belongs to same store' do
      store2 = create(:store)
      payment_method.store_ids = [store2.id]
      payment_method.save
      expect(payment_method.available_for_store?(store)).to eq(false)
    end
  end
end
