module Transbank
  module Webpay
    module WebpayPlus
      class MallTransactionCommitResponse
        FIELDS = %i[
          vci
          details
          buy_order
          session_id
          card_detail
          accounting_date
          transaction_date
        ].freeze
        attr_accessor(*FIELDS)

        def initialize(json)
          FIELDS.each { |field| send("#{field}=", json[field.to_s])}
        end
      end
    end
  end
end
