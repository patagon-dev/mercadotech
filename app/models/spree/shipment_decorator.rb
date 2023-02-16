module Spree::ShipmentDecorator
  def self.prepended(base)
    base.include Spree::ShipmentEnums
    base.belongs_to :enviame_carrier
    base.belongs_to :enviame_carrier_service
    base.has_many :shipment_labels

    base.whitelisted_ransackable_attributes += ['reference_number']

    # shipment state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    base.state_machine initial: :pending, use_transactions: false do
      event :ready do
        transition from: %i[pending pickup packed waiting attention], to: :ready, if: lambda { |shipment|
          # Fix for #2040
          shipment.determine_state(shipment.order) == 'ready'
        }
      end
      event :wait do
        transition from: %i[ready pickup packed], to: :waiting
      end
      event :alert do
        transition from: %i[ready pickup packed], to: :attention
      end
      event :pick do
        transition from: %i[waiting attention ready packed], to: :pickup
      end
      event :pack do
        transition from: %i[waiting attention pickup], to: :packed
      end
      event :cancel do
        transition to: :canceled, from: %i[pending ready pickup packed waiting attention]
      end
      event :ship do
        transition from: %i[ready canceled pickup packed], to: :shipped
      end
    end

    base.scope :pickup, -> { with_state('pickup') }
    base.scope :packed, -> { with_state('packed') }
    base.scope :invalid, -> { with_state('canceled') }
    base.after_update :product_reviews_notify, if: :saved_change_to_state?
  end

  def product_reviews_notify
    product_ids = line_items.map { |it| it.product }.pluck(:id)
    if shipped?
      Spree::ShipmentMailer.product_reviews_notification(id, product_ids).deliver_later(wait: 2.weeks)
    end
  end

  def after_cancel
    manifest.each { |item| manifest_restock(item) } # restock
    refund_webpay_payment_if_any if order.complete?
  end

  def ready_to_ship?
    %w[ready pickup packed].include?(state)
  end

  def determine_state(order)
    return 'canceled' if order.canceled? || state == 'canceled'
    return 'pending' unless order.can_ship?
    return 'pending' if inventory_units.any?(&:backordered?)
    return 'shipped' if shipped?

    order.complete? ? 'ready' : 'pending'
  end

  def get_carriers
    return [] unless stock_location.vendor && (stock_location.vendor.enviame_carriers.present? || eligible_for_moova?)

    carriers = stock_location.vendor.enviame_carriers.map { |sr| [sr.name, sr.id] }
    carriers.insert(0, [Spree.t(:moova_api), 'moova']) if eligible_for_moova?
    carriers
  end

  def carrier_used
    moova_shipment_id.present? ? Spree.t(:moova_api) : enviame_carrier&.name
  end

  private

  def eligible_for_moova?
    stock_location.vendor.enable_moova? &&
      stock_location.google_place_id &&
      stock_location.latitude &&
      stock_location.longitude &&
      has_moova_zone?
  end

  def has_moova_zone?
    moova_zones = Spree::Zone.moova
    return false if !shipping_method || !moova_zones.any?

    moova_zones.any? { |z| z.include?(order.ship_address)} && (shipping_method.zones & moova_zones).any?
  end

  # Partial refund on shipment cancelation
  def refund_webpay_payment_if_any
    webpay_payment = order.payments.completed.from_webpay.where('vendor_id = ? and amount > ?', stock_location.vendor_id, 0).take

    if webpay_payment
      refund_payment = create_refund_payment(webpay_payment.payment_method_id)

      provider = webpay_payment.payment_method.provider.new(order.number, final_price_with_items.to_f, webpay_payment.number)
      provider.nullify_payment(webpay_payment.vendor_id, refund_payment.number) ? refund_payment.update(state: 'completed') : refund_payment.update(state: 'refund_pending')
    end

    if order.shipments.pluck(:state).uniq.all? { |st| st == 'canceled' } # check all shipments canceled
      order.update_column(:state, 'canceled')
      order.log_state_changes(state_name: 'order', old_state: 'completed', new_state: 'canceled')
      order.send(:send_cancel_email)
    end
    order.update_with_updater!
  end

  # Mark in spree when payment is partially refunded for webpay
  def create_refund_payment(payment_method_id)
    order.payments.create!({
                             payment_method_id: payment_method_id,
                             vendor_id: stock_location.vendor_id,
                             amount: final_price_with_items.to_f * -1
                           })
  end

  ::Spree::Shipment.prepend self
end
