require 'uri'
require 'net/http'
require 'timeout'

module StockApi
  class ApiService
    attr_reader :line_item, :stock_location

    def initialize(line_item_id, stock_location_id)
      @line_item = Spree::LineItem.find_by(id: line_item_id)
      @stock_location = Spree::StockLocation.find_by(id: stock_location_id)
    end

    def execute
      { success: process_request, product_name: line_item.name }
    end

    private

    def process_request
      Timeout.timeout(25) do
        api_url = stock_location.stock_api_url + "#{replace_caret_symbol_with_hex_encode}/#{line_item.quantity}"

        url = URI(api_url)
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request['Authorization'] = basic_auth_token
        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        response = https.request(request)
        parsed_response = JSON.parse(response.body)
        if parsed_response.present? && response.code == '200'
          parsed_response['isavailable']
        end
      end
    rescue Timeout::Error
      true
    rescue Exception => e
      puts "Exception occured #{e}"
      true # by pass api in case of any exception
    end

    def replace_caret_symbol_with_hex_encode
      sku = line_item.sku.split('_', 2)[1]
      sku.include?('^') ? sku.gsub('^', '%5E') : sku
    end

    def basic_auth_token
      "Basic #{Base64.strict_encode64("#{Rails.application.credentials.dig(:stock_api, :username)}:#{Rails.application.credentials.dig(:stock_api, :password)}")}"
    end
  end
end
