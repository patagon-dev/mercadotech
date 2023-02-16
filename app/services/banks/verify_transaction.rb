require 'uri'
require 'net/http'

module Banks
  class VerifyTransaction

    attr_accessor :vendor, :transaction_url

    def initialize(transaction_url, id)
      @refund_history = Spree::RefundHistory.find_by(id: id)
      @vendor = @refund_history.vendor
      @transaction_url = transaction_url

      response = check_transaction_status
      parsed_response = JSON.parse(response.body)

      if response.code == '200'
        (parsed_response["is_success"] == false) ? @refund_history.update_columns(status: 'failed', failure_reason: parsed_response ) : @refund_history.update_column(:status, 'completed')
      else
        @refund_history.update_column(:failure_reason, parsed_response)
      end
    end

    private

    def check_transaction_status
      url = URI(transaction_url)

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request['Accept'] = 'application/json'
      request['Authorization'] = basic_auth_token
      request['Content-Type'] = 'application/json'
      response = https.request(request)
    end

    def basic_auth_token
      "Basic #{Base64.strict_encode64("#{vendor.bank_transfer_login}:#{vendor.bank_transfer_password}")}"
    end
  end
end
