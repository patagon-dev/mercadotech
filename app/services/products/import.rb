require 'net/http'
require 'open-uri'

class Products::Import
  attr_reader :vendor

  SCRAPINGHUB_BASE_URL = 'https://storage.scrapinghub.com'.freeze
  SCRAPINGHUB_JOB_ENDPOINT = 'https://app.scrapinghub.com'.freeze

  def initialize(vendor_id)
    @vendor = Spree::Vendor.find(vendor_id)
  end

  def from_csv
    if vendor.products_csv_url.present?
      path = "tmp/#{vendor.name}_#{Time.now.strftime('%s')}_products.csv"

      puts "Started downloading file for #{vendor.name}"
      download_file(path, vendor.products_csv_url)

      puts "started saving products for #{vendor.name}"
      Products::Importer.new(path, vendor.id).import
    end
  end

  def from_xml
    return unless vendor.products_xml_url

    path = "tmp/#{vendor.name}_#{Time.now.strftime('%s')}_products.xml"

    puts "Started downloading file for #{vendor.name}"
    download_file(path, vendor.products_xml_url)

    puts "started saving products for #{vendor.name}"
    Products::XmlImporter.new(path, vendor.id).import
  end

  def from_full_scraping_hub
    scraping_hub_base(vendor.full_spider, true)
  end

  def from_quick_scraping_hub
    scraping_hub_base(vendor.quick_spider, false)
  end

  def scraping_hub_base(spider_name, full_spider)
    path = "tmp/#{vendor.name}_scrapinghub_#{Time.now.strftime('%s')}.xml"

    puts 'Get last finished Job Id'
    job_id = get_scrapinghub_job_id(spider_name)

    puts "Scraping hub last finished job Id: #{job_id}"
    unless job_id.present?
      puts "Job ID not found"
      return
    end

    puts "Started downloading file for #{vendor.name}"
    download_scrapinghub_xml_file(path, job_id)

    puts "Started saving products for #{vendor.name}"
    Products::ScrapingHubImporter.new(path, vendor.id, full_spider).import
  end

  private

  def download_file(path, import_file_url)
    open(path, 'wb') do |file|
      file << open(import_file_url).read
    end
  end

  def download_scrapinghub_xml_file(path, job_id)
    uri = URI.parse("#{SCRAPINGHUB_BASE_URL}/items/#{job_id}?format=xml")
    response = execute_scraping_hub_api(uri)

    open(path, 'wb') do |file|
      file << response.body
    end
  end

  def get_scrapinghub_job_id(spider_name)
    uri = URI.parse("#{SCRAPINGHUB_JOB_ENDPOINT}/api/jobs/list.json?project=#{vendor.scrapinghub_project_id}&spider=#{spider_name}&state=finished&count=1")
    response = execute_scraping_hub_api(uri)
    if response.code == "200"
      response_body = JSON.parse(response.body)['jobs']
      return response_body[0]['id'] if response_body.present?
    else
      nil
    end
  end

  def execute_scraping_hub_api(uri)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(vendor.scrapinghub_api_key.to_s, '')

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
