module SpiderManager
  class Items < SpiderManager::Base
    attr_reader :job_id, :job, :path

    def initialize(vendor_id, job_id)
      super
      @job = Spree::SpiderManagement.find_by(job_id: job_id)
      @job_id = job_id
      @path = "#{job_id.split('/').last}-#{vendor_id}-#{Time.current}__.json"
    end

    def perform
      return { status: :error, message: Spree.t(:job_id_not_found, scope: :spider_management) } if job_id.blank?

      response = process_request
      if response.code == '200'
        open(path, 'wb') do |file|
          file << response.body
        end
        attached_scraped_items_logs
        @result = { status: :success, message: response.message }
      else
        Rails.logger.error "Spider: #{spider_type}. Message: #{@parsed_response['message']}"
        @result = { status: :error, message: @parsed_response['message'] }
      end

      @result
    end

    def attached_scraped_items_logs
      if job.scraped_item_log.attached?
        persisted_log_file = job.scraped_item_log.attachments.select { |att| [path].include?(att.blob.filename.to_s) }
        persisted_log_file.each(&:destroy) if persisted_log_file.any?
      end

      attached_response = job.scraped_item_log.attach(io: File.open(path), filename: path)
      File.delete(path) if attached_response
    end

    private

    def process_request
      url = URI(request_url)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request['Authorization'] = basic_aouth

      response = https.request(request)
    end

    def request_url
      "#{SCRAPINGHUB_ITEMS_URL}/#{job_id}"
    end
  end
end
