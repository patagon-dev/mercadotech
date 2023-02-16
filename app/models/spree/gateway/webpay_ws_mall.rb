module Spree
  # Gateway for Transbank Webpay Webservice Mall Hosted Payment Pages solution
  class Gateway::WebpayWsMall < Gateway
    def self.STATE
      'webpay_ws_mall'
    end

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def provider_class
      Transbank::Webpay::WebpayPlus::Payment
    end

    def provider
      provider_class
    end

    def actions
      %w[capture]
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    # For deffered payment only [Not in use currently]
    def capture(_money_cents, _response_code, gateway_options)
      gateway_order_id = gateway_options[:order_id]
      payment_number   = gateway_order_id.split('-').last

      payment = Spree::Payment.find_by(number: payment_number)
      order   = payment.order

      provider = payment.payment_method.provider.new payment, order

      if provider.capture_payment
        ActiveMerchant::Billing::Response.new(true,  make_success_message(payment.webpay_params), {}, {})
      else
        ActiveMerchant::Billing::Response.new(false, make_failure_message(payment.webpay_params), {}, {})
      end
    end

    # Using for capturing negative payments for refund purpose
    def refund_payment(money_cents, response_code, gateway_options)
      gateway_order_id = gateway_options[:order_id]
      refund_payment_number   = gateway_order_id.split('-').last

      refund_payment = Spree::Payment.find_by(number: refund_payment_number) #Negative Payment for refund
      order   = refund_payment.order

      #webpay payment used to send token in api
      webpay_payment = order.payments.completed.from_webpay.where("vendor_id = ? and amount > ?", refund_payment.vendor_id, 0).take

      provider = refund_payment.payment_method.provider.new(order.number, refund_payment.amount.abs.to_f, webpay_payment.number)
      if provider.nullify_payment(refund_payment.vendor_id, refund_payment_number)
        ActiveMerchant::Billing::Response.new(true,  Spree.t(:refund_success), {state: 'complete'}, {})
      else
        ActiveMerchant::Billing::Response.new(false, Spree.t(:refund_error), {state: 'refund_pending'}, {})
      end
    end

    def cancel(number)
      payment = Spree::Payment.find_by(number: number) # Original Payment
      provider = payment.payment_method.provider.new(payment.order.number, payment.amount.to_f, number)
      if provider.nullify_payment(payment.vendor_id, number) # Refund
        ActiveMerchant::Billing::Response.new(true, '', { state: 'void' }, {})
      else
        ActiveMerchant::Billing::Response.new(true, '', { state: 'refund_pending' }, {})
      end
    end

    def auto_capture?
      false
    end

    def method_type
      'webpay_ws_mall'
    end

    def credit(_money, _credit_card, _response_code, _options = {})
      ActiveMerchant::Billing::Response.new(true, '#{Spree::Gateway::WebpayWsMall.to_s}: Forced success', {}, {})
    end

    def void(_response_code, _options = {})
      ActiveMerchant::Billing::Response.new(true, '#{Spree::Gateway::WebpayWsMall.to_s}: Forced success', {}, {})
    end

    def payment_method_logo
      'http://www.puntopagos.com/content/mp3.gif'
    end

    private

    def make_success_message(webpay_params)
      "#{webpay_params['buy_order']} - Código Autorización: #{webpay_params['authorization_code']}"
    end

    def make_failure_message(webpay_params)
      webpay_params['authorization_code']
    end
  end
end
