require 'faraday'

module Sendy
  class Client
    def initialize
      @url = Rails.application.credentials.dig(:sendy, :api_url)
      @key = Rails.application.credentials.dig(:sendy, :api_key)
    end

    def subscribe(list_id, email, name = nil)
      response = connection.post 'subscribe' do |req|
        params = { api_key: @key, list: list_id, email: email, boolean: true }
        params[:name] = name if name
        req.body = params
      end

      !!(response.body =~ /^1$/)
    end

    def unsubcribe(list_id, email)
      response = connection.post 'unsubscribe', { list: list_id, email: email, boolean: true }

      !!(response.body =~ /^1$/)
    end

    def subscription_status(list_id, email)
      response = connection.post 'api/subscribers/subscription-status.php' do |req|
        req.body = { list_id: list_id, email: email, api_key: @key }
      end

      response.body
    end

    def active_subscriber_count(list_id)
      response = connection.post 'api/subscribers/active-subscriber-count.php' do |req|
        req.body = { list_id: list_id, api_key: @key }
      end

      response.body
    end

    protected

    def connection
      @connection ||= Faraday.new(url: @url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
