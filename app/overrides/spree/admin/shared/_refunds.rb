Deface::Override.new(
  virtual_path: 'spree/admin/shared/_refunds',
  name: 'refunds',
  replace: "erb[loud]:contains('payment_method_name(refund.payment)')" ,
  text: <<-HTML
            <%= refund.refund_type.present? ? refund.refund_type : payment_method_name(refund.payment) %>
    HTML
  )