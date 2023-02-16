require 'uri'
require 'net/http'
require 'timeout'

module CompetitorPrice
  class Api
    attr_reader :solotodo_id

    def initialize(solotodo_id)
      @solotodo_id = solotodo_id
    end

    def execute
      process_request
    end

    private

    def process_request
      api_url = average_price_api_url + "#{solotodo_id}/"

      url = URI(api_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request['Authorization'] = basic_auth_token
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      response = https.request(request)
      parsed_response = JSON.parse(response.body)
      parsed_response['results'] if parsed_response['results'].present?
    rescue Exception => e
      puts "Exception occured #{e}"
    end

    def basic_auth_token
      "Basic #{Base64.strict_encode64("#{Rails.application.credentials.dig(:competitor_price,
                                                                           :username)}:#{Rails.application.credentials.dig(
                                                                             :competitor_price, :password
                                                                           )}")}"
    end

    def average_price_api_url
      Rails.application.credentials.dig(:competitor_price, :api_url)
    end
  end
end
