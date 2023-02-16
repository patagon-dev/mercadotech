module Spree::PaymentDecorator
  EXTERNAL_PAYMENT_METHODS = %w(Spree::Gateway::WebpayOneclickMall Spree::Gateway::WebpayWsMall).freeze

  def self.prepended(base)
    base.scope :from_webpay_ws_mall, -> { joins(:payment_method).where(spree_payment_methods: { type: Spree::Gateway::WebpayWsMall.to_s }) }
    base.scope :from_oneclick_mall, -> { joins(:payment_method).where(spree_payment_methods: { type: Spree::Gateway::WebpayOneclickMall.to_s }) }
    base.scope :from_webpay, -> { joins(:payment_method).where(spree_payment_methods: { type: [Spree::Gateway::WebpayWsMall.to_s, Spree::Gateway::WebpayOneclickMall.to_s] }) }
    base.scope :from_external, -> { joins(:payment_method).where(spree_payment_methods: { type: EXTERNAL_PAYMENT_METHODS }) }

    base.scope :accepted,            -> { where(accepted: true) }
    base.scope :webpay_accepted,     -> { select { |p| p.webpay_params.present? && p&.webpay_params['detailOutput1']&.downcase&.include?('<responsecode>0</responsecode>')} }
    base.scope :refund_pending, -> { with_state('refund_pending') }
    base.scope :refunded, -> { with_state('refunded') }

    base.after_initialize :set_webpay_ws_trx_id
    base.include Spree::VendorConcern

    base.state_machine initial: :checkout do
      event :refund_pending do
        transition from: %i[pending processing completed checkout], to: :refund_pending
      end
      event :refunded do
        transition from: [:refund_pending], to: :refunded
      end
      event :complete do
        transition from: %i[processing pending checkout refund_pending], to: :completed
      end
    end

    def base.by_webpay_ws_token(token)
      find_by(webpay_token: token)
    end
  end

  def webpay_ws_mall?
    payment_method.type == Spree::Gateway::WebpayWsMall.to_s
  end

  def webpay_ws_mall_token
    webpay_token
  end

  def webpay_ws_mall_transaction_params
    webpay_ws_mall_params_values('detailOutput1')
  end

  def webpay_ws_mall_params_card_number
    webpay_params['cardNumber']
  end

  def webpay_ws_mall_trx_details(value)
    webpay_params['detail_output'][value.to_s]
  rescue StandardError
    nil
  end

  def webpay_ws_mall_params_values(key)
    webpay_params[key] || {}
  rescue JSON::ParserError => e
    Rails.logger.error e
    {}
  end

  def uncaptured_amount
    money_in_cents = Spree::Money.new(amount, currency: currency).amount_in_cents
    money_in_cents - captured_amount
  end

  def webpay_ws_mall_params_amount
    Nokogiri::HTML(webpay_ws_mall_transaction_params).xpath('//amount').text.to_i
  end

  def webpay_ws_mall_params_commerce_code
    Nokogiri::HTML(webpay_ws_mall_transaction_params).xpath('//commercecode').text.to_i
  end

  def webpay_ws_mall_params_buyorder
    webpay_ws_mall_trx_details('buyorder')
  end

  def webpay_ws_mall_params_authorization_code
    webpay_ws_mall_trx_details('authorizationcode')
  end

  def webpay_ws_mall_params_payment_type_code
    webpay_ws_mall_trx_details('paymenttypecode')
  end

  def webpay_ws_mall_params_response_code
    webpay_ws_mall_trx_details('responsecode').present? ? webpay_ws_mall_trx_details('responsecode').to_i : ''
  end

  def webpay_ws_mall_params_installments
    webpay_ws_mall_trx_details('sharesnumber').present? ? webpay_ws_mall_trx_details('sharesnumber').to_i : ''
  end

  def webpay_trx_success
    webpay_ws_mall_params_response_code == 0
  end

  def complete_and_next
    logger = TbkLogger.new payment: self, order: order
    complete
  end

  def invalidate_old_payments
    # invalid payment or store_credit payment shouldn't invalidate other payment types
    return if has_invalid_state? || store_credit? || webpay_ws_mall? || oneclick_mall?

    order.payments.with_state('checkout').where.not(id: id).each do |payment|
      payment.invalidate! unless payment.store_credit?
    end
  end

  def oneclick_mall?
    payment_method.type == Spree::Gateway::WebpayOneclickMall.to_s
  end

  def eligible_for_api_refund?
    vendor&.bank_transfer_url && !amount_refunded? && check_default_bank_account_exist?
  end

  def oneclick_params_values
    webpay_params || {}
  rescue JSON::ParserError => e
    Rails.logger.error e
    {}
  end

  def oneclick_params_authorize
    @oneclick_authorize_params ||= oneclick_params_values
  end

  def oneclick_params_detail
    oneclick_params_authorize['detail_output']
  end

  def oneclick_params_authorization_date
    oneclick_params_authorize['authorization_date']
  end

  def oneclick_params_authorization_code
    oneclick_params_detail['authorizationcode']
  end

  def oneclick_params_response_code
    oneclick_params_detail['responsecode']
  end

  def oneclick_params_amount
    oneclick_params_detail['amount']
  end

  def oneclick_params_payment_type_code
    oneclick_params_detail['paymenttypecode']
  end

  def oneclick_params_shares_number
    oneclick_params_detail['sharesnumber']
  end

  def oneclick_params_commerce_id
    oneclick_params_detail['commercecode']
  end

  def oneclick_params_buy_order
    oneclick_params_detail['buyorder']
  end

  def oneclick_user_params
    @oneclick_user_params ||= JSON.parse(oneclick_params_values['oneclick_user'])
  end

  def oneclick_user
    Tbk::WebpayOneclickMall::User.find_by(id: oneclick_user_params_authorize['id']) if oneclick_user_params.present?
  end

  def oneclick_params_card_number
    oneclick_user_params['card_number']
  end

  def oneclick_params_card_origin
    oneclick_user_params['card_origin']
  end

  def oneclick_params_card_type
    oneclick_user_params['card_type']
  end

  def oneclick_params_subscription_authorization_code
    oneclick_user_params['authorization_code']
  end

  def oneclick_params_subscription_token
    oneclick_user_params['token']
  end

  def oneclick_params_tbk_user
    oneclick_user_params['tbk_user']
  end

  private

  def set_webpay_ws_trx_id
    self.webpay_trx_id ||= generate_webpay_ws_trx_id
  end

  def generate_webpay_ws_trx_id
    Digest::MD5.hexdigest("#{order.number}#{order.payments.count}") if order
  end

  def check_default_bank_account_exist?
    order.user ? order.user.bank_accounts&.default&.any? : Spree::BankAccount.guest_user_account(order.email).default.any?
  end

  Spree::Payment.prepend self
end
