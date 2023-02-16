require 'uri'
require 'net/http'

module Keycloak
  class GetUsers
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def execute
      process_request
    end

    private

    def process_request
      api_url = "#{Rails.application.credentials.dig(:keycloak, :url)}admin/realms/mercadoempresas/users?max=50000"

      url = URI(api_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request['Accept'] = '*/*'
      request['Authorization'] = bearer_auth_token
      response = https.request(request)
      JSON.parse(response.body)
    rescue Exception => e
      puts "Exception occured #{e}"
    end

    def bearer_auth_token
      "Bearer #{token}"
    end
  end
end
