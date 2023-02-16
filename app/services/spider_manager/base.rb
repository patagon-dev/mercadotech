require 'uri'
require 'net/http'

module SpiderManager
  class Base
    attr_reader :vendor, :spider_type

    SCRAPINGHUB_URL = 'https://app.scrapinghub.com'
    SCRAPINGHUB_ITEMS_URL = 'https://storage.scrapinghub.com/items'

    def initialize(vendor_id, spider_type)
      @vendor = Spree::Vendor.find_by(id: vendor_id)
      @spider_type = spider_type
    end

    def perform
      return { status: :error, message: Spree.t(:spider_not_found, scope: :spider_management) } if spider_type.blank?

      response = process_request
      @parsed_response = JSON.parse(response.body)

      if response.code == '200'
        save_spider_logs(@parsed_response['jobs']) if @parsed_response['jobs'].present?
        @result = { status: :success, message: response.message }
      else
        Rails.logger.error "Spider: #{spider_type}. Message: #{@parsed_response['message']}"
        @result = { status: :error, message: @parsed_response['message'] }
      end

      @result
    end

    private

    def save_spider_logs(logs)
      logs.each do |log|
        attributes = spider_attribute(log)
        spider_log = Spree::SpiderManagement.find_by(job_id: log['id'])
        begin
          if spider_log.present?
            spider_log.update!(attributes)
          else
            spider_log = Spree::SpiderManagement.new(attributes)
            spider_log.save
          end
          spider_log.save
        rescue Exception => e
          Rails.logger.error "Spider: #{spider_type}. Message: #{e}"
        end
      end
    end

    def spider_attribute(data)
      attts = {
        job_id: data['id'],
        spider_name: data['spider'],
        items: data['items_scraped'],
        requests: data['responses_received'],
        close_reason: data['close_reason'],
        finished: data['updated_time'],
        vendor_id: vendor&.id
      }

      attts.compact
    end

    def basic_aouth
      "Basic #{Base64.strict_encode64("#{vendor.scrapinghub_api_key}:")}"
    end
  end
end
