require 'uri'
require 'net/http'

module Keycloak
  class AccessToken
    def execute
      process_request
    end

    private

    def process_request
      api_url = "#{Rails.application.credentials.dig(:keycloak, :url)}realms/master/protocol/openid-connect/token"

      url = URI(api_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(url)
      request['Accept'] = '*/*'
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = URI.encode_www_form(parameters)
      response = https.request(request)
      parsed_response = JSON.parse(response.body)
      parsed_response['access_token'] if parsed_response['access_token'].present?
    rescue Exception => e
      puts "Exception occured #{e}"
    end

    def parameters
      {
        client_id: 'admin-cli',
        username: Rails.application.credentials.dig(:keycloak, :username),
        password: Rails.application.credentials.dig(:keycloak, :password),
        grant_type: 'password',
        client_secret: Rails.application.credentials.dig(:keycloak, :client_secret)
      }
    end
  end
end
