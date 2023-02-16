module Transbank
  module Webpay
    module WebpayPlus
      class Base
        DEFAULT_API_KEY = WebpayMallNormalConfig::DEFAULT_API_KEY

        DEFAULT_COMMERCE_CODE = WebpayMallNormalConfig::DEFAULT_COMMERCE_CODE
        DEFAULT_INTEGRATION_TYPE = WebpayMallNormalConfig::DEFAULT_INTEGRATION_TYPE

        @api_key = DEFAULT_API_KEY
        @commerce_code = DEFAULT_COMMERCE_CODE
        @integration_type = DEFAULT_INTEGRATION_TYPE
        @integration_types = {
          LIVE: 'https://webpay3g.transbank.cl/',
          TEST: 'https://webpay3gint.transbank.cl/'
        }
        class << self
          attr_reader :integration_types
          attr_accessor :api_key, :integration_type, :commerce_code

          def integration_type_url(integration_type)
            type = integration_type.upcase.to_sym
            return @integration_types[type] unless @integration_types[type].nil?

            valid_values = @integration_types.keys.join(', ')
            raise Transbank::Webpay::Errors::IntegrationTypeError, "Invalid integration type, valid values are #{valid_values}"
          end

          def current_integration_type_url
            @integration_types[@integration_type]
          end

          def integration_type=(integration_type)
            type = integration_type.upcase.to_sym
            return @integration_type = type unless @integration_types[type].nil?

            valid_values = @integration_types.keys.join(', ')
            raise Transbank::Webpay::Errors::IntegrationTypeError, "Invalid integration type, valid values are #{valid_values}"
          end

          def configure_for_testing
            @api_key = DEFAULT_API_KEY
            @commerce_code = DEFAULT_COMMERCE_CODE
            self.integration_type = :TEST
          end
        end
      end
    end
  end
end
