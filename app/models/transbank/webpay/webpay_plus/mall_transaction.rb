module Transbank
  module Webpay
    module WebpayPlus
      class MallTransaction
        extend Transbank::Utils::NetHelper
        CREATE_TRANSACTION_ENDPOINT = 'rswebpaytransaction/api/webpay/v1.0/transactions'.freeze
        COMMIT_TRANSACTION_ENDPOINT = 'rswebpaytransaction/api/webpay/v1.0/transactions'.freeze
        TRANSACTION_STATUS_ENDPOINT = 'rswebpaytransaction/api/webpay/v1.0/transactions/:token'.freeze
        REFUND_TRANSACTION_ENDPOINT = 'rswebpaytransaction/api/webpay/v1.0/transactions/:token/refunds'.freeze
        class << self
          def create(buy_order:, session_id:, return_url:, details:, options: nil)
            api_key = options&.api_key || default_integration_params[:api_key]
            commerce_code = options&.commerce_code || default_integration_params[:commerce_code]
            integration_type = options&.integration_type || default_integration_params[:integration_type]
            base_url = integration_type.nil? ? WebpayPlus::Base.integration_type[:TEST] : WebpayPlus::Base.integration_type_url(integration_type)

            url = base_url + CREATE_TRANSACTION_ENDPOINT
            headers = webpay_headers(commerce_code: commerce_code, api_key: api_key)
            body = { buy_order: buy_order,
                     session_id: session_id,
                     details: details,
                     return_url: return_url }
            resp = http_post(uri_string: url, body: body, headers: headers, camel_case_keys: false)
            json = JSON.parse(resp.body)
            return ::Transbank::Webpay::WebpayPlus::TransactionCreateResponse.new(json) if resp.is_a? Net::HTTPSuccess

            raise Errors::TransactionCreateError.new(json['error_message'], resp.code)
          end

          def commit(token:, options: nil)
            api_key = options&.api_key || default_integration_params[:api_key]
            commerce_code = options&.commerce_code || default_integration_params[:commerce_code]
            integration_type = options&.integration_type || default_integration_params[:integration_type]
            base_url = integration_type.nil? ? WebpayPlus::Base.integration_type[:TEST] : WebpayPlus::Base.integration_type_url(integration_type)
            url = base_url + "#{COMMIT_TRANSACTION_ENDPOINT}/#{token}"
            headers = webpay_headers(commerce_code: commerce_code, api_key: api_key)
            resp = http_put(uri_string: url, body: {}, headers: headers)
            json = JSON.parse(resp.body)
            if resp.is_a? Net::HTTPSuccess
              return ::Transbank::Webpay::WebpayPlus::MallTransactionCommitResponse.new(json)
            end

            raise Errors::TransactionCommitError.new(json['error_message'], resp.code)
          end

          def refund(token:, buy_order:, child_commerce_code:, amount:, options: nil)
            api_key = options&.api_key || default_integration_params[:api_key]
            commerce_code = options&.commerce_code || default_integration_params[:commerce_code]
            integration_type = options&.integration_type || default_integration_params[:integration_type]
            base_url = integration_type.nil? ? WebpayPlus::Base.integration_type[:TEST] : WebpayPlus::Base.integration_type_url(integration_type)
            url = base_url + REFUND_TRANSACTION_ENDPOINT.to_s.gsub(':token', token)
            headers = webpay_headers(commerce_code: commerce_code, api_key: api_key)
            body = {
              buy_order: buy_order,
              commerce_code: child_commerce_code,
              amount: amount
            }
            resp = http_post(uri_string: url, body: body, headers: headers, camel_case_keys: false)
            json = JSON.parse(resp.body)
            return ::Transbank::Webpay::WebpayPlus::TransactionRefundResponse.new(json) if resp.is_a? Net::HTTPSuccess

            raise Errors::TransactionRefundError.new(json['error_message'], resp.code)
          end

          def status(token:, options: nil)
            api_key = options&.api_key || default_integration_params[:api_key]
            commerce_code = options&.commerce_code || default_integration_params[:commerce_code]
            integration_type = options&.integration_type || default_integration_params[:integration_type]
            base_url = integration_type.nil? ? WebpayPlus::Base.integration_type[:TEST] : WebpayPlus::Base.integration_type_url(integration_type)
            url = base_url + TRANSACTION_STATUS_ENDPOINT.to_s.gsub(':token', token)
            headers = webpay_headers(commerce_code: commerce_code, api_key: api_key)

            resp = http_get(uri_string: url, headers: headers)
            json = JSON.parse(resp.body)
            if resp.is_a? Net::HTTPSuccess
              return ::Transbank::Webpay::WebpayPlus::MallTransactionStatusResponse.new(json)
            end

            raise Errors::TransactionStatusError.new(json['error_message'], resp.code)
          end

          def default_integration_params
            {
              api_key: WebpayPlus::Base.api_key,
              commerce_code: WebpayPlus::Base.commerce_code,
              integration_type: WebpayPlus::Base.integration_type,
              base_url: WebpayPlus::Base.current_integration_type_url
            }
          end
        end
      end
    end
  end
end
