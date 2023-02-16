# frozen_string_literal: true

module Tbk::WebpayWsMallCore
  class Constant
    PAYMENT_TYPES = {
      'VN' => 'Crédito',
      'VC' => 'Crédito',
      'VD' => 'Débito',
      'SI' => 'Crédito',
      'S2' => 'Crédito',
      'NC' => 'Crédito'
    }.freeze

    INSTALMENT_TYPES = {
      'VN' => 'Sin Cuotas',
      'VC' => 'Cuotas Normales',
      'VD' => 'Venta Debito',
      'SI' => 'Sin Interés',
      'S2' => 'Sin Interés',
      'NC' => 'Sin Interés'
    }.freeze

    TBK_TOKEN = :token_ws
    TBK_FAILURE_TOKEN = 'TBK_TOKEN'
  end
end
