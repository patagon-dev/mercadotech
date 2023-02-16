module Spree::OrderUpdaterDecorator
  def update_payment_state
    last_state = order.payment_state
    if payments.present? && payments.valid.empty?
      order.payment_state = 'failed'
    elsif order.canceled? && order.payment_total == 0
      order.payment_state = if order.payments.valid.refund_pending.any?
                              'refund_pending'
                            else
                              'void'
                            end
    else
      order.payment_state = 'balance_due' if order.outstanding_balance > 0
      order.payment_state = 'credit_owed' if order.outstanding_balance < 0
      order.payment_state = 'paid' unless order.outstanding_balance?
    end
    order.state_changed('payment') if last_state != order.payment_state
    order.payment_state
  end

  def update_shipment_state
    if order.backordered?
      order.shipment_state = 'backorder'
    else
      # get all the shipment states for this order
      shipment_states = shipments.states
      order.shipment_state = if shipment_states.size > 1
                               # multiple shipment states means it's most likely partially shipped
                               (shipment_states.size == 2) && (shipment_states.sort == %w[canceled shipped].sort) ? 'shipped' : 'partial'
                             else
                               # will return nil if no shipments are found
                               shipment_states.first
                               # TODO: inventory unit states?
                               # if order.shipment_state && order.inventory_units.where(shipment_id: nil).exists?
                               #   shipments exist but there are unassigned inventory units
                               #   order.shipment_state = 'partial'
                               # end
                             end
    end

    order.state_changed('shipment')
    order.shipment_state
  end

  Spree::OrderUpdater.prepend self
end
