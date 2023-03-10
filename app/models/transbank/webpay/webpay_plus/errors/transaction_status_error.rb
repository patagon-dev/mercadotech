module Transbank
  module Webpay
    module WebpayPlus
      module Errors
        class TransactionStatusError < ::Transbank::Webpay::Errors::WebpayError
          attr_reader :code

          def initialize(message, code)
            @code = code
            super(message, code)
          end
        end
      end
    end
  end
end
