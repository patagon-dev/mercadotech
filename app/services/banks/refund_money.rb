require 'uri'
require 'net/http'

module Banks
  class RefundMoney
    attr_reader :vendor, :reference, :refund_amount, :bank_account

    def initialize(reference_number, refund_amount, vendor_id)
      @reference = Spree::Payment.find_by(number: reference_number) || Spree::Reimbursement.find_by(number: reference_number)
      @vendor = Spree::Vendor.find_by(id: vendor_id)
      @refund_amount = refund_amount.round # Set 1 for testing
      @bank_account = default_bank_account
    end

    def execute
      return { success: false, message: Spree.t(:not_found, scope: :bank_account) } unless bank_account.present?

      response = process_request
      @parsed_response = JSON.parse(response.body)

      if response.code == '200'
        @transaction_id = @parsed_response['id_transferencia']
        if @parsed_response['id_transferencia'].present?
          @result =  { success: true, message: Spree.t(:refund_successfully, scope: :bank_account) }
        else
          @result = { success: true, message: @parsed_response['mensaje'] }
        end
        create_refund_history
      else
        @result = { success: false, message: @parsed_response }
      end

      @result
    end

    private

    def process_request
      url = URI(vendor.bank_transfer_url)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json'
      request['Authorization'] = basic_auth_token
      request['Content-Type'] = 'application/json'
      request.body = parameters.to_json
      response = https.request(request)
    end

    def parameters
      Rails.env.production? ? actual_parameters : test_parameters
    end

    def actual_parameters
      {
        monto: refund_amount,
        cuenta_destino: bank_account.account_number,
        banco_destino: bank_account.code,
        RUT_titular: bank_account.rut,
        email: bank_account.email,
        mensaje: reference.number,
        nombre_titular_destino: bank_account.name
      }
    end

    def test_parameters
      {
        monto: 1,
        cuenta_destino: '61205691',
        banco_destino: '0000',
        RUT_titular: '102688899',
        email: 'nmella@uc.cl',
        mensaje: 'Test message',
        nombre_titular_destino: 'John smith'
      }
    end

    def basic_auth_token
      "Basic #{Base64.strict_encode64("#{vendor.bank_transfer_login}:#{vendor.bank_transfer_password}")}"
    end

    def create_refund_history
      if @result[:success]
        refund_history = Spree::RefundHistory.new(user_id: bank_account.user_id,
                                                  vendor_id: vendor.id,
                                                  amount: refund_amount,
                                                  reference_number: reference.number,
                                                  refund_type: 'Spree::WireTransfer',
                                                  refund_response: @parsed_response,
                                                  transaction_id: @transaction_id)
        refund_history.save
      end
    end

    def default_bank_account
      @reference.order&.user ? @reference.order&.user&.bank_accounts&.default&.take : Spree::BankAccount.guest_user_account(@reference.order&.email).default&.take
    end
  end
end
