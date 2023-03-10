module Transbank
  module Webpay
    module WebpayPlus
      class TransactionStatusResponse
        FIELDS =
          %i[vci amount buy_order session_id
             card_detail accounting_date transaction_date
             authorization_code payment_type_code response_code
             installments_amount installments_number balance].freeze

        attr_accessor(*FIELDS)

        def initialize(json)
          FIELDS.each { |field| send("#{field}=", json[field.to_s]) }
        end
      end
    end
  end
end
