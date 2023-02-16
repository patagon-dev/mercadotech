Deface::Override.new(
  virtual_path: 'spree/admin/payments/_form',
  name: 'hide refund payment methods if not credit owed',
  insert_after: "erb[loud]:contains('Spree.t(:payment_method)')",
  text:       <<-HTML
                <% @payment_methods = @payment_methods - Spree::PaymentMethod.where(type: Spree::PaymentMethod::REFUND_PAYMENT_METHODS) if @order.payment_state != "credit_owed" %>
              HTML
)
