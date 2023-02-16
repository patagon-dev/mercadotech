class UpdateShipmentStatusJob < ApplicationJob
  queue_as :others

  def perform(order_ids, status)
    orders = Spree::Order.where(id: order_ids)
    states = { 'ready' => 'ready!', 'pickup' => 'pick!', 'packed' => 'pack!', 'waiting' => 'wait!', 'attention' => 'alert!' }

    orders.each do |order|
      ApplicationRecord.transaction do
        shipments = order.shipments

        shipments.each do |shipment|
          next unless shipment.persisted?

          transition_state = states[status]
          shipment.send(transition_state)
        end

        order.shipment_state = status
        order.state_changed('shipment')
        order.save!
      end
    rescue Exception => e
      puts e
      next
    end
  end
end
