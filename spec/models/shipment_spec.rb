# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Shipment do
  let(:shipment) { create(:shipment, order: create(:completed_order_with_pending_payment)) }

  context 'associations' do
    it { should belong_to(:enviame_carrier).optional }
    it { should belong_to(:enviame_carrier_service).optional }
    it { should have_many(:shipment_labels) }
  end

  context 'state_machine' do
    it 'should include custom states in shipment' do
      expect(Spree::Shipment.state_machines[:state].states.map(&:name)).to include(:waiting, :attention, :pickup, :packed)
    end

    it 'should change state to waiting or attention' do
      shipment.state = %w[ready pickup packed].sample
      shipment.save

      shipment_states = { 'wait' => 'waiting', 'alert' => 'attention' }
      selected_state = shipment_states.keys.sample
      shipment.send(selected_state)

      expect(shipment.reload.state).to eq(shipment_states[selected_state])
    end

    it 'should change state to pickup' do
      valid_state = %w[waiting attention ready packed].sample
      shipment.state = valid_state
      shipment.save
      shipment.pick

      expect(shipment.reload.state).to eq('pickup')
    end

    it 'should change state to packed' do
      valid_state = %w[waiting attention pickup].sample
      shipment.state = valid_state
      shipment.save
      shipment.pack

      expect(shipment.reload.state).to eq('packed')
    end
  end

  context 'instance methods' do
    it 'should check shipment ready to ship' do
      valid_state = %w[ready pickup packed].sample
      shipment.state = valid_state
      shipment.save

      expect(shipment.ready_to_ship?).to eq(true)
    end

    context 'determine shipment state' do
      it 'should return shipment state ready if order complete' do
        expect(shipment.determine_state(shipment.order)).to eq('ready')
      end

      it 'should return shipment state shipped' do
        shipment.state = 'shipped'
        shipment.save

        expect(shipment.determine_state(shipment.order)).to eq('shipped')
      end

      context 'should return pending' do
        before do
          shipment.order.state = 'payment'
          shipment.order.save
          shipment.inventory_units.update_all(state: 'backordered')
        end
        it 'if order not complete || if order cannot be shipped || if any backordered inventory units' do
          expect(shipment.determine_state(shipment.order)).to eq('pending')
        end
      end
    end

    context '#after_cancel' do
      it 'should make partial refund of shipment total and create negative payment' do
        order = create(:completed_order_with_pending_payment)
        external_methods = %i[webpay_payment_method webpay_oneclick_payment_method]
        payment = create(:payment, order: order, payment_method: create(external_methods.sample), amount: order.total.to_f, accepted: true)
        payment.complete

        order.shipments.first.cancel!
        expect(%w[refund_pending complete].include?(order.reload.payments.where('amount < ?', 0).pluck(:state).uniq[0])).to eq(true)
      end
    end

    context 'carrier used' do
      it 'should return moova' do
        shipment.moova_shipment_id = 'abcd-efgh-ijkl'
        shipment.save

        expect(shipment.carrier_used).to eq(Spree.t(:moova_api))
      end

      it 'should return enviame_carrier' do
        shipment_with_enviame = create(:shipment_with_enviame)

        expect(shipment_with_enviame.carrier_used).to eq(shipment_with_enviame.enviame_carrier.name)
      end
    end
  end
end
