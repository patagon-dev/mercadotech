module Transbank
  module Webpay
    module Oneclick
      module Errors
        class MallTransactionAuthorizeError < OneclickError
          attr_accessor :code, :message

          def initialize(message, code)
            @code = code
            @message = message
            super(message, code)
          end
        end
      end
    end
  end
end
