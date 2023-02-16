module SpiderManager
  class ManageLogs < SpiderManager::Base
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
      "#{SCRAPINGHUB_URL}/api/jobs/list.json?project=#{vendor&.scrapinghub_project_id}&spider=#{spider_type}"
    end
  end
end
