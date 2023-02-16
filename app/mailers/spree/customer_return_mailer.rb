class Spree::CustomerReturnMailer < Spree::BaseMailer
  def email_notification(order_id)
    order = Spree::Order.find_by(id: order_id)
    @current_store = order.store
    mail(to: order.email, from: @current_store.mail_from_address, subject: Spree.t(:subject, scope: :return_product))
  end
end