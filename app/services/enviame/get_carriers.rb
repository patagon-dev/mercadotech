module Enviame
  class GetCarriers
    require 'uri'
    require 'net/http'

    def run
      Spree::Vendor.where('enviame_vendor_id is not NULL').each do |vendor|
        @current_store = Spree::Store.where(id: vendor.import_store_ids).take
        puts "Started saving for #{vendor.name}"
        url = URI(get_carriers_url(vendor))

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request['Accept'] = 'application/json'
        request['api-key'] = enviame_api_key
        response = https.request(request)

        carriers = JSON.parse(response.body)['data']

        puts 'Starting saving Carriers'

        carriers.each do |carrier|
          puts "Saving #{carrier['name']}"

          enviame_carrier = Spree::EnviameCarrier.find_or_create_by(name: carrier['name'], code: carrier['code'], country: carrier['country'])
          enviame_carrier.vendors << vendor unless enviame_carrier.vendors.include?(vendor)

          next unless carrier['configurations'].present?

          carrier['configurations'].each do |service|
            enviame_carrier.enviame_carrier_services.find_or_create_by(service_attrs(service))
          end
        end
        puts 'Done saving Carriers'
      end
    end

    private

    def service_attrs(service)
      {
        name: service['name'],
        code: service['code'],
        description: service['description'],
        default: service['default']
      }
    end

    def enviame_api_key
      Rails.application.credentials.dig(@current_store.code&.to_sym, :enviame, :api_key)
    end

    def get_carriers_url(vendor)
      "#{Rails.application.credentials.dig(@current_store.code&.to_sym, :enviame, :carriers_url)}/#{vendor.enviame_vendor_id}/carriers"
    end
  end
end
