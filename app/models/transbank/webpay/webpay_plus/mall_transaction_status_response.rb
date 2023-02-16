module Transbank
  module Webpay
    module WebpayPlus
      class MallTransactionStatusResponse
        FIELDS = %i[
          buy_order
          session_id
          card_detail
          expiration_date
          accounting_date
          transaction_date
          details
        ].freeze
        attr_accessor(*FIELDS)

        def initialize(json)
          FIELDS.each { |field| send("#{field}=", json[field.to_s])}
        end
      end
    end
  end
end
