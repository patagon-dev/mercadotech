module SpiderManager
  class RunJob < SpiderManager::Base
    private

    def parameters
      [
        ['project', vendor&.scrapinghub_project_id],
        ['spider', spider_type]
      ]
    end

    def process_request
      url = URI(request_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = basic_aouth
      form_data = parameters
      request.set_form form_data, 'multipart/form-data'

      response = https.request(request)
    end

    def request_url
      "#{SCRAPINGHUB_URL}/api/run.json"
    end
  end
end
