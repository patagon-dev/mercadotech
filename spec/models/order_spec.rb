# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Order do
  let(:order) do
    order = create(:order_with_line_items, state: 'payment')
    order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, Spree::Vendor.first&.id) }
    order.reload
  end

  context 'shipment states' do
    it 'should include custom shipment state' do
      expect(Spree::Order::SHIPMENT_STATES).to include('pickup', 'packed', 'waiting', 'attention')
    end
  end

  context 'custom checkout steps' do
    it 'should have include custom checkout steps' do
      expect(Spree::Order.checkout_step_names).to include(:oneclick_mall, :webpay_ws_mall, :freeze)
    end

    it 'should have webpay_ws_mall if order has webpay normal as payment method' do
      create(:payment, order: order, payment_method: create(:webpay_payment_method), amount: order.total, accepted: true)
      order.next!
      expect(order.state).to eq('webpay_ws_mall')
    end

    it 'should have oneclick_mall checkout step if order has oneclick mall payment method' do
      create(:payment, order: order, payment_method: create(:webpay_oneclick_payment_method), amount: order.total, accepted: true)
      order.next!
      expect(order.state).to eq('oneclick_mall')
    end

    it 'should not include confirm as checkout steps' do
      expect(Spree::Order.checkout_step_names).not_to include('confirm')
    end
  end

  context 'Bypass Stock' do
    it 'should by pass stock during webpay transaction and restore back to default after complete' do
      create(:payment, order: order, payment_method: create(:webpay_payment_method), amount: order.total, accepted: true)
      order.next!
      product = order.products.take
      product.master.stock_items.update_all(count_on_hand: 0, backorderable: false) # Due to import, stock can be set as 0 or less then order quantity
      order.ensure_line_items_are_in_stock # by pass stock, in order callback

      expect(product.master.reload.by_pass_stock).to eq(true)
      order.next!
      expect(order.state).to eq('complete')
      # expect(product.master.reload.by_pass_stock).to eq(false) # restore by_pass_stock after transaction
    end
  end

  context 'attributes and associations' do
    it 'should include store and invoice in ransack associations' do
      expect(Spree::Order.whitelisted_ransackable_associations).to include('invoices')
    end

    it 'should include additional attributes in ransack search' do
      expect(Spree::Order.whitelisted_ransackable_attributes).to include('reference_order_numbers')
    end
  end

  context 'associations' do
    it { should have_many(:micro_compra_purchase_orders) }
    it { should have_many(:customer_purchase_orders) }
    it { should have_many(:invoices) }
  end

  describe 'instance methods' do
    context '#returnable_period' do
      it 'should be returnable within 60 days of purchase' do
        allow(order).to receive_messages payment_required?: false
        order.next!
        expect(order.returnable_period).to eq(true)
      end

      it 'should not returnable after 60 days of purchase' do
        allow(order).to receive_messages payment_required?: false
        order.next!
        order.completed_at = Time.zone.now - 3.months
        order.save

        expect(order.returnable_period).to eq(false)
      end
    end

    context '#allow_cancel?' do
      it 'should allow cancel when shipment state is pickup or packed' do
        allow(order).to receive_messages payment_required?: false
        order.next!
        order.shipment_state = %w[pickup packed].sample
        order.save

        expect(order.allow_cancel?).to eq(true)
      end
    end

    context '#outstanding_balance' do
      it 'should match outstanding_balance when any shipment invalid' do
        vendor1 = create(:vendor, name: 'test123')
        product = create(:product, shipping_category: create(:shipping_category, vendor_id: vendor1.id), vendor_id: vendor1.id)

        product.master.stock_items.first.adjust_count_on_hand(10)
        create(:line_item, variant: product.master, order: order)
        create(:shipment, order: order, cost: rand(10..100))
        order.update_with_updater!
        Spree::StockLocation.where(vendor_id: nil).update_all(vendor_id: vendor1.id)
        create(:payment, order: order, payment_method: create(:webpay_payment_method), amount: order.total, accepted: true)
        2.times { order.next! }

        order.shipments.first.cancel!

        expect(order.outstanding_balance).to eq(order.shipments.valid.map(&:final_price_with_items).sum - order.payment_total)
      end
    end

    context '#after_cancel' do
      it 'should cancel the payments of external payment methods' do
        external_methods = %i[webpay_payment_method webpay_oneclick_payment_method]
        payment = create(:payment, order: order, payment_method: create(external_methods.sample), amount: order.total, accepted: true)
        2.times { order.next! }
        payment.complete

        order.cancel!
        expect(%w[refund_pending void].include?(order.reload.payments.pluck(:state).uniq[0])).to eq(true)
      end
    end
  end
end
