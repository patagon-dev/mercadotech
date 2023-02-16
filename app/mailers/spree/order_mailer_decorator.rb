module Spree::OrderMailerDecorator
  def confirm_email(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    @current_store = @order.store
    super
  end

  def cancel_email(order, resend = false)
    @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    @current_store = @order.store
    super
  end
  Spree::OrderMailer.prepend Spree::OrderMailerDecorator
end
