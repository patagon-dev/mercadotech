module Transbank
  module Webpay
    module WebpayPlus
      class TransactionRefundResponse
        FIELDS =
          %i[type authorize_code authorization_date nullified_amount
             balance response_code].freeze

        attr_accessor(*FIELDS)

        def initialize(json)
          FIELDS.each { |field| send("#{field}=", json[field.to_s]) }
        end
      end
    end
  end
end
