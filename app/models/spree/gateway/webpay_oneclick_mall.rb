module Spree
  # Gateway for Transbank Webpay Hosted Payment Pages solution
  class Gateway::WebpayOneclickMall < Gateway
    def self.STATE
      'oneclick_mall'
    end

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def provider_class
      Transbank::Webpay::Oneclick::Payment
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

    def capture(_money_cents, response_code, gateway_options)
      gateway_order_id   = gateway_options[:order_id]
      order_number       = gateway_order_id.split('-').first
      payment_identifier = gateway_order_id.split('-').last

      payment = Spree::Payment.find_by(number: payment_identifier)
      order   = payment.order

      response_code = payment.oneclick_params_response_code
      if payment.webpay_params.present?
        if response_code == '0'
          ActiveMerchant::Billing::Response.new(true,  make_message(order.number, response_code), {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, make_message(order.number, response_code), {}, {})
        end
      else
        ActiveMerchant::Billing::Response.new(false, "Transacción no aprobada #{payment.webpay_params}", {}, {})
      end
    end

    # negative payments for refund purpose
    def refund_payment(money_cents, response_code, gateway_options)
      gateway_order_id = gateway_options[:order_id]
      payment_number   = gateway_order_id.split('-').last

      payment = Spree::Payment.find_by(number: payment_number)
      order   = payment.order

      provider = payment.payment_method.provider.new order.number, payment.amount.abs.to_f
      if provider.nullify_payment(payment.vendor_id, payment_number)
        ActiveMerchant::Billing::Response.new(true,  Spree.t(:refund_success), {state: 'complete'}, {})
      else
        ActiveMerchant::Billing::Response.new(false, Spree.t(:refund_error), {state: 'refund_pending'}, {})
      end
    end

    # Full refund on order cancel
    def cancel(number)
      payment = Spree::Payment.find_by(number: number)
      provider = payment.payment_method.provider.new payment.order.number, payment.amount.to_f
      if provider.nullify_payment(payment.vendor_id, number)
        ActiveMerchant::Billing::Response.new(true, '', { state: 'void' }, {})
      else
        ActiveMerchant::Billing::Response.new(true, '', { state: 'refund_pending' }, {})
      end
    end

    def auto_capture?
      false
    end

    def method_type
      self.class.STATE
    end

    def credit(_money, _credit_card, _response_code, _options = {})
      ActiveMerchant::Billing::Response.new(true, '#{self.class.to_s}: Forced success', {}, {})
    end

    def void(_response_code, _options = {})
      ActiveMerchant::Billing::Response.new(true, '#{self.class.to_s}: Forced success', {}, {})
    end

    def payment_method_logo
      ActionController::Base.helpers.asset_path('oneclick_logo.png')
    end

    def logo
      payment_method_logo
    end

    def available_for_order?(_order)
      _order.user.present?
    end

    private

    def make_message(order_number, authorization_code)
      "#{order_number} - Código Autorización: #{authorization_code}"
    end
  end
end
