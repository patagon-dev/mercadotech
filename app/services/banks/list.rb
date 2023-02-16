require 'uri'
require 'net/http'

module Banks
  class List
    def run
      url = URI(bank_list_url)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request['Accept'] = 'application/json'
      request['Authorization'] = basic_auth_token
      response = https.request(request)

      if response.code == '200'
        @bank_data = JSON.parse(response.body)
        save_bank_details
      else
        puts "Error getting in fetching bank list: #{JSON.parse(response.body)}"
      end
    end

    private

    def save_bank_details
      @bank_data.each do |bank_name, bank_code|
        bank = Spree::Bank.new(name: bank_name, code: bank_code)
        unless bank.save
          puts "Error saving bank details for #{bank_name} due to - #{bank.errors.full_messages.join(', ')}"
        end
      end
    end

    def basic_auth_token
      "Basic #{Base64.strict_encode64("#{Rails.application.credentials.dig(:banks, :login)}:#{Rails.application.credentials.dig(:banks, :password)}")}"
    end

    def bank_list_url
      Rails.application.credentials.dig(:banks, :list_url)
    end
  end
end

# RESPONSE DATA EXAMPLE:
# {"ABN AMRO BANK (CHILE)"=>"0046", "BANCO BICE"=>"0028", "BANCO CHILE"=>"0001", "BANCO CONSORCIO"=>"0055", "BANCO DE CREDITOS E INVERSIONES"=>"0016", "BANCO DEL DESARROLLO"=>"0507", "BANCO DEL ESTADO DE CHILE"=>"0012", "BANCO FALABELLA"=>"0051", "BANCO INTERNACIONAL"=>"0009", "BANCO ITAU CHILE"=>"0039", "BANCO PARIS"=>"0057", "BANCO RIPLEY"=>"0053", "BANCO SECURITY"=>"0049", "COOPEUCH"=>"0672", "CORPBANCA"=>"0027", "HSBC BANK (CHILE)"=>"0031", "PREPAGO LOS HEROES"=>"0729", "RABOBANK CHILE"=>"0054", "SCOTIABANK AZUL"=>"0504", "SCOTIABANK SUD AMERICANO"=>"0014", "TENPO PREPAGO S.A."=>"0730"}
