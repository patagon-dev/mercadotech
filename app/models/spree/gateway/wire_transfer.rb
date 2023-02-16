class Spree::Gateway::WireTransfer < Spree::Gateway
  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    payment.pending? || payment.checkout?
  end

  def actions
    %w[capture]
  end

  def source_required?
    false
  end

  def method_type
    'wire_transfer'
  end

  def refund_payment(money_cents, response_code, gateway_options)
    gateway_order_id = gateway_options[:order_id]
    payment_number   = gateway_order_id.split('-').last

    payment = Spree::Payment.find_by(number: payment_number)
    return false unless payment

    order = payment.order
    response = Banks::RefundMoney.new(payment.number, payment.amount.abs, payment.vendor_id).execute

    if response[:success]
      payment.update_column(:amount_refunded, true)
      state = payment.amount > 0 ? 'refunded' : 'complete'
      payment.send(state)
      ActiveMerchant::Billing::Response.new(true,  Spree.t(:refund_successfully, scope: :bank_account), {state: 'complete'}, {})
    else
      ActiveMerchant::Billing::Response.new(false,  response[:message], {state: 'refund_pending'}, {})
    end
  end
end
