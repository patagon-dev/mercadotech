require 'uri'
require 'net/http'

module CommentTool
  class SignupApi
    attr_reader :email, :name

    def initialize(email, name)
      @email = email
      @name = name
    end

    def execute
      process_request
    end

    private

    def process_request
      api_url = Rails.application.credentials.dig(:comment_tool, :signup_url)

      url = URI(api_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request.body = parameters.to_json
      response = https.request(request)
      parsed_response = JSON.parse(response.body)
      parsed_response['success']
    rescue Exception => e
      puts "Exception occured #{e}"
    end

    def parameters
      {
        email: email,
        name: name,
        password: '1234',
        website: ''
      }
    end
  end
end
