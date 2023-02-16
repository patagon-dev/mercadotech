module Spree::ShipmentMailerDecorator
  def shipped_email(shipment, resend = false)
    @shipment = shipment.respond_to?(:id) ? shipment : Spree::Shipment.find(shipment)
    @current_store = @shipment.order.store
    super
  end

  def return_shipping_label_notification(order_id, blob)
    order = Spree::Order.find_by(id: order_id)
    @order_number = order.number
    @current_store = order.store
    filename = blob.filename.to_s
    attachments[filename] = { mime_type: 'application/pdf', content: blob.download }
    mail(to: order.email, from: @current_store.mail_from_address, subject: Spree.t(:return_shipping_label_subject))
  end

  def product_reviews_notification(shipment_id, product_ids)
    @shipment = Spree::Shipment.find_by(id: shipment_id)
    @products = Spree::Product.where(id: product_ids)
    @current_store = @shipment.order.store
    mail(to: @shipment.order.email, from: @current_store.mail_from_address, subject: Spree.t(:product_reviews_notification))
  end

  Spree::ShipmentMailer.prepend Spree::ShipmentMailerDecorator
end
