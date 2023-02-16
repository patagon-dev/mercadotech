require 'uri'
require 'net/http'

module CommentTool
  class LoginApi
    attr_reader :email

    def initialize(email)
      @email = email
    end

    def execute
      process_request
    end

    private

    def process_request
      api_url = Rails.application.credentials.dig(:comment_tool, :login_url)

      url = URI(api_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request.body = parameters.to_json
      response = https.request(request)
      parsed_response = JSON.parse(response.body)
      parsed_response['commenterToken']
    rescue Exception => e
      puts "Exception occured #{e}"
    end

    def parameters
      {
        email: email,
        password: '1234'
      }
    end
  end
end
