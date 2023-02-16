module Spree::RefundDecorator
  def description
    refund_type? ? refund_type : payment.payment_method.name
  end

  ::Spree::Refund.prepend self
end
