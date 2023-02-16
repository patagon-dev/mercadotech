module Transbank
  module Webpay
    module WebpayPlus
      class Payment
        attr_reader :order, :amount, :token, :vendors, :session_id, :return_url, :payment

        def initialize(order_number, amount, payment_number, confirmation_path = nil)
          @order = Spree::Order.find_by(number: order_number)
          @payment = Spree::Payment.find_by(number: payment_number) || @order.payments.valid.last
          @token = @payment.webpay_token
          @session_id = @payment.webpay_trx_id
          @payment_method_id = @payment.payment_method_id
          @vendors = @order.get_vendors
          @amount = amount
          @shares_number = 0
          @return_url = confirmation_path

          @logger = TbkLogger.new payment: @payment, order: @order
        end

        def init_transaction
          @logger.log_info(action: 'payment.actions.wi', content: I18n.t('payment.msgs.init.start_transaction'))
          begin
            details = build_details_params
            @logger.log_info(action: 'payment.actions.wi', content: "VENDORS STORE DATA: #{details.inspect}")

            @init_response = Transbank::Webpay::WebpayPlus::MallTransaction.create(buy_order: order.number,
                                                                                   session_id: session_id,
                                                                                   return_url: return_url,
                                                                                   details: details)

            @logger.log_info(action: 'payment.actions.wi', content: "INIT TRANSACTION RESULT: #{@init_response.inspect}")
          rescue Exception => e
            @logger.log_info(action: 'payment.actions.wi', content: I18n.t('payment.msgs.init.not_connected'))
            @logger.log_error(action: 'payment.actions.wi', content: "Confirmation Error : E -> #{e.message}")
            @logger.log_error(action: 'payment.actions.wi', content: "Confirmation Error : E -> #{e.backtrace}")
            return false
          end
          handle_init_response
        end

        def get_confirmation
          begin
            @logger.log_info(action: 'payment.actions.wc', content: 'CALLING GET_TRANSACTION_RESULT')
            @confirmate_response = Transbank::Webpay::WebpayPlus::MallTransaction.commit(token: token)

            @logger.log_info(action: 'payment.actions.wa', content: "GET_TRANSACTION_RESULT DATA: #{@confirmate_response.inspect}")
          rescue Exception => e
            @logger.log_error(action: 'payment.actions.wc', content: "Confirmation Error : E -> #{e.message}")
            @logger.log_error(action: 'payment.actions.wc', content: "Confirmation Error : E -> #{e.backtrace}")
            return false
          end
          handle_confirmate_response
        end

        def nullify_payment(vendor_id, reference_number)
          @reference = Spree::Payment.find_by(number: reference_number) || Spree::Reimbursement.find_by(number: reference_number)
          @vendor = Spree::Vendor.find_by(id: vendor_id)
          @refund_type = @reference.class.name == 'Spree::Payment' ? @reference.payment_method.type : 'Spree::ReimbursementType::WebpayNormal'

          begin
            @refund_response = Transbank::Webpay::WebpayPlus::MallTransaction.refund(token: token,
                                                                                     buy_order: "#{vendor_id}-#{order.number}",
                                                                                     child_commerce_code: @vendor.webpay_ws_mall_store_code,
                                                                                     amount: amount)

            @logger.log_info(action: 'payment.actions.wa', content: "GET_Refund_Response DATA: #{@refund_response.inspect}")
          rescue Exception => e
            @logger.log_error(action: 'payment.actions.wc', content: "Confirmation Error : E -> #{e.message}")
            @logger.log_error(action: 'payment.actions.wc', content: "Confirmation Error : E -> #{e.backtrace}")
            return false
          end
          handle_refund_response
        end

        private

        def build_details_params
          vendors.map do |vendor|
            {
              amount: vendor.total_amount(order),
              commerce_code: vendor.webpay_ws_mall_store_code,
              buy_order: "#{vendor.id}-#{order.number}"
            }
          end
        end

        def create_vendor_payment
          order.payments.destroy_all  # Destroy old payments
          @logger.log_info(action: 'payment.actions.wa', content: 'CREATING VENDOR PAYMENTS')

          vendors.each_with_index do |vendor, index|
            order.payments.create(vendor_payment_params(vendor, @confirmate_response.details[index]))
          end
        end

        def vendor_payment_params(vendor, detail)
          {
            amount: detail['amount'],
            payment_method_id: @payment_method_id,
            vendor_id: vendor.id,
            webpay_token: token,
            webpay_params: {
              accountingDate: @confirmate_response.accounting_date,
              buyOrder: @confirmate_response.buy_order,
              cardNumber: @confirmate_response.card_detail['card_number'],
              sessionId: @confirmate_response.session_id,
              transactionDate: @confirmate_response.transaction_date,
              oneclick_user: nil,
              vci: @confirmate_response.vci,
              detail_output: {
                sharesnumber: detail['installments_number'],
                commercecode: detail['commerce_code'],
                buyorder: detail['buy_order'],
                authorizationcode: detail['authorization_code'],
                responsecode: detail['response_code'],
                paymenttypecode: detail['payment_type_code'],
                shares_amount: detail['installments_amount']
              }
            }
          }
        end

        def handle_init_response
          if @init_response.token.present?
            @logger.log_info(action: 'payment.actions.wi', content: I18n.t('payment.msgs.init.transaction_ok'))
            payment.update_column(:webpay_token, @init_response.token)
            @init_response
          else
            @logger.log_error(action: 'payment.actions.wi', content: I18n.t('payment.msgs.init.incorrect_data'))
            false
          end
        end

        def handle_confirmate_response
          if @confirmate_response.details.present?
            create_vendor_payment
            confirm_payment_response
          else
            @logger.log_info(action: 'payment.actions.wa', content: I18n.t('payment.msgs.ack.invalid_response_code', token_tbk: token, response: @confirmate_response.inspect))
            false
          end
        end

        def handle_refund_response
          if @refund_response.present? && (@refund_response.type == 'REVERSED' || @refund_response.type == 'NULLIFIED')
            refund_history = Spree::RefundHistory.new(user_id: order.user_id, vendor_id: @vendor.id, amount: amount, reference_number: @reference.number, refund_type: @refund_type, refund_response: @refund_response)
            refund_history.save

            true
          else
            false
          end
        end

        def confirm_payment_response
          # api response and return if all payments are failed.
          return false unless order.payments.map { |payment| payment.webpay_ws_mall_params_response_code }.include? 0

          # spree opertaions
          begin
            unless order.state == Spree::Gateway::WebpayWsMall.STATE
              order.update_column(:state, Spree::Gateway::WebpayWsMall.STATE)
            end
            order.next! unless order.complete?
            @logger.log_info(action: 'payment.actions.wc', content: "CONFIRMATION: After order next! - #{order.inspect}")
          rescue StandardError => e
            order.freeze!
            @logger.log_error(action: 'payment.actions.wc', content: "CONFIRMATION ERROR: #{e} ORDER: #{order.inspect}")
            @logger.log_error(action: 'payment.actions.wc', content: I18n.t('payment.msgs.confirmation.freeze_order', number: order.number, message: e.message))
          end

          @logger.log_info(action: 'payment.actions.wc', content: 'UPDATING PAYMENTS')
          order.payments.each do |payment|
            if payment.webpay_ws_mall_params_response_code.eql?(0)
              payment.update_column(:accepted, true)
              payment.complete_and_next
            else
              payment.pend
              payment.failure
              next
            end
          end

          @logger.log_info(action: 'payment.actions.wc', content: I18n.t('payment.msgs.confirmation.send_wk'))
          @logger.log_info(action: 'payment.actions.wc', content: I18n.t('payment.msgs.confirmation.ok'))
          true
        end
      end
    end
  end
end
