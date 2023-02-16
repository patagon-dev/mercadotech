# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::OrderUpdater do
  let(:order) do
    order = create(:order_with_line_items, state: 'payment')
    order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, Spree::Vendor.first&.id) }
    order.reload
  end

  context 'update_payment_state' do
    before do
      external_methods = %i[webpay_payment_method webpay_oneclick_payment_method]
      payment = create(:payment, order: order, payment_method: create(external_methods.sample), amount: order.total, accepted: true)
      2.times { order.next! }
      payment.complete

      order.cancel!
      allow(Spree::OrderUpdater.new(order)).to receive(:update).and_return(true)
    end

    it 'should expect order payment state to be in void or refund_pending' do
      expect(%w[refund_pending void].include?(order.payment_state)).to eq(true)
    end
  end

  context 'update_shipment_state' do
    before do
      vendor2 = create(:vendor, name: 'New Vendor 2')
      product = create(:product, shipping_category: create(:shipping_category, vendor_id: vendor2.id), vendor_id: vendor2.id)

      product.master.stock_items.first.adjust_count_on_hand(10)
      create(:line_item, variant: product.master, order: order)

      shipment = create(:shipment, order: order, cost: 20)
      shipment.add_shipping_method(create(:shipping_method, name: 'Vendor2 Shipping Method', vendor: vendor2), true)
      order.update_with_updater!
      Spree::StockLocation.where(vendor_id: nil).update_all(vendor_id: vendor2.id)
      create(:payment, order: order, payment_method: create(:webpay_payment_method), amount: order.total, accepted: true)
      2.times { order.next! }

      order.shipments.first.cancel!
      order.shipments.last.ship
      allow(Spree::OrderUpdater.new(order)).to receive(:update).and_return(true)
    end

    it 'should expect order shipment state to be shipped if any shipment is shipped' do
      expect(order.reload.shipment_state).to eq('shipped')
    end
  end
end
