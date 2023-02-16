module Transbank
  module Webpay
    module Oneclick
      class MallInscriptionFinishResponse
        FIELDS = %i[response_code tbk_user authorization_code
                    card_type card_number].freeze
        attr_accessor(*FIELDS)

        def initialize(json)
          FIELDS.each { |field| send("#{field}=", json[field.to_s]) }
        end
      end
    end
  end
end
