module Transbank
  module Webpay
    module Oneclick
      class Payment
        attr_reader :order, :amount, :oneclick_user, :username, :vendors

        def initialize(order_number, amount, oneclick_user_id = nil)
          @order = Spree::Order.find_by(number: order_number)
          @oneclick_user = Tbk::WebpayOneclickMall::User.find_by(id: oneclick_user_id)
          @payment_method_id = Spree::PaymentMethod.where(type: Spree::Gateway::WebpayOneclickMall.to_s).take&.id
          @vendors = @order&.get_vendors
          @amount = amount
          @shares_number = @oneclick_user&.shares_number || 1
          @username = order.user.rut.present? ? order.user.rut : order.billing_address.company_rut

          @logger = OneclickLogger.new payment: nil, order: order
        end

        def run
          return false unless oneclick_user

          response_status = authorize_payments
          create_vendor_payment if response_status
          confirmate_response # Update payment states according to response
        end

        def nullify_payment(vendor_id, reference_number)
          @reference = Spree::Payment.find_by(number: reference_number) || Spree::Reimbursement.find_by(number: reference_number)
          @vendor = Spree::Vendor.find_by(id: vendor_id)
          @refund_type = @reference.class.name == 'Spree::Payment' ? @reference.payment_method.type : 'Spree::ReimbursementType::WebpayOneClick'

          begin
            @refund_response = Transbank::Webpay::Oneclick::MallTransaction.refund(buy_order: order.number,
                                                                                   child_commerce_code: @vendor.webpay_oneclick_store_code,
                                                                                   child_buy_order: "#{vendor_id}-#{order.number}",
                                                                                   amount: amount)

            @logger.log_info(action: 'payment.oneclick.actions.response', content: I18n.t('payment.oneclick.refund_response', args: @refund_response.inspect.to_s))
          rescue Exception => e
            @logger.log_info(action: 'payment.oneclick.actions.failure', content: I18n.t('payment.oneclick.api_error', args: e.to_s))
            return false
          end
          handle_refund_response
        end

        private

        def authorize_payments
          details = build_details_params
          @response = Transbank::Webpay::Oneclick::MallTransaction.authorize(username: username,
                                                                             tbk_user: oneclick_user.tbk_user,
                                                                             parent_buy_order: order.number,
                                                                             details: details)

          @logger.log_info(action: 'payment.oneclick.actions.response', content: I18n.t('payment.oneclick.auth_response', args: @response.inspect.to_s))
          @response.details.present?
        end

        def build_details_params
          vendors.map do |vendor|
            {
              commerce_code: vendor.webpay_oneclick_store_code,
              buy_order: "#{vendor.id}-#{order.number}",
              amount: vendor.total_amount(order),
              installments_number: @shares_number
            }
          end
        end

        def create_vendor_payment
          @logger.log_info(action: 'payment.oneclick.actions.destroy', content: I18n.t('payment.oneclick.destroy_payment'))
          order.payments.destroy_all # Destroy old payments

          vendors.each_with_index do |vendor, index|
            @logger.log_info(action: 'payment.oneclick.actions.vendor_payment', content: I18n.t('payment.oneclick.vendor_payments', args: vendor.name.to_s))
            order.payments.create(vendor_payment_params(vendor, @response.details[index]))
          end
        end

        def vendor_payment_params(vendor, detail)
          {
            amount: detail['amount'],
            payment_method_id: @payment_method_id,
            vendor_id: vendor.id,
            webpay_token: oneclick_user.token,
            webpay_params: {
              accountingDate: @response.accounting_date,
              buyOrder: @response.buy_order,
              cardNumber: @response.card_detail['card_number'],
              sessionId: nil,
              transactionDate: @response.transaction_date,
              oneclick_user: oneclick_user.to_json,
              vci: nil,
              detail_output: {
                sharesnumber: detail['installments_number'],
                commercecode: vendor.webpay_oneclick_store_code,
                buyorder: detail['buy_order'],
                authorizationcode: detail['authorization_code'],
                responsecode: detail['response_code'],
                paymenttypecode: detail['payment_type_code'],
                shares_amount: detail['installments_amount']
              }
            }
          }
        end

        def handle_refund_response
          if @refund_response.present? && %w[REVERSED NULLIFIED].include?(@refund_response.type)
            refund_history = Spree::RefundHistory.new(user_id: @order.user_id, vendor_id: @vendor.id, amount: amount, reference_number: @reference.number, refund_type: @refund_type, refund_response: @refund_response)
            refund_history.save
            true
          else
            false
          end
        end

        def confirmate_response
          # api response and return if all payments are failed.
          return false unless order.payments.map { |payment| payment.oneclick_params_response_code }.include? 0

          # spree operations
          begin
            unless order.state == Spree::Gateway::WebpayOneclickMall.STATE
              order.update_column(:state, Spree::Gateway::WebpayOneclickMall.STATE)
            end
            @logger.log_info(action: 'payment.oneclick.actions.order_state', content: I18n.t('payment.oneclick.update_order_state'))
            order.next! unless @order.complete?
          rescue Exception => e
            order.freeze!
            @logger.log_info(action: 'payment.oneclick.actions.confirm_error', content: I18n.t('payment.oneclick.confirm_error', args: e.to_s))
            @logger.log_info(action: 'payment.oneclick.actions.confirm_error', content: I18n.t('payment.oneclick.confirm_error', args: e.backtrace.to_s))
          end

          @logger.log_info(action: 'payment.oneclick.actions.update_payment', content: I18n.t('payment.oneclick.update_payment'))
          order.payments.each do |payment|
            if payment.oneclick_params_response_code.eql?(0)
              payment.update_column(:accepted, true)
              payment.complete_and_next
            else
              payment.pend
              payment.failure
              next
            end
          end
          true
        end
      end
    end
  end
end
