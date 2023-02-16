class NewsletterSubscriptionJob < ApplicationJob
  queue_as :default

  def perform(key, email, store_code)
    api_response = Sendy::Client.new.subscribe(key, email)
    if api_response
      ActiveSupport::Cache::RedisCacheStore.new.send(:write_entry, "#{store_code}/#{email}", email)
    end
  end
end
