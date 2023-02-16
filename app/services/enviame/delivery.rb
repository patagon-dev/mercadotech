require 'open-uri'

module Enviame
  class Delivery
    attr_reader :vendor, :shipment, :order

    def initialize(shipment_number)
      @shipment = Spree::Shipment.find_by(number: shipment_number)
      @vendor = @shipment.stock_location.vendor
      @order = @shipment.order
      @chx_carrier = !!@shipment.enviame_carrier&.code&.include?('CHX')
      @current_store_code = @order.store&.code
    end

    def create
      if @chx_carrier
        shipment.n_packages.times do |idx|
          @shipment_index = idx + 1
          generate_shipping_label
        end
      else
        generate_shipping_label
      end

      @result
    end

    protected

    def parameters
      {
        shipping_order: shipping_order_data,
        shipping_origin: shipping_origin_data,
        shipping_destination: shipping_destination_data,
        shipping_carrier: shipping_carrier_data
      }
    end

    def warehouse_parameters
      ship_address = order.ship_address
      full_ship_address = [ship_address.full_street_address, ship_address.county&.name, ship_address.city].compact.join(', ')
      {
        name: vendor.name,
        code: SecureRandom.hex(4), # Added customer address as random code
        place: ship_address.county&.name,
        full_address: full_ship_address
      }
    end

    def shipping_order_data
      shipping_weight = order.vendor_items_weight(vendor)
      shipping_weight = 0.1 if shipping_weight < 0.1

      {
        imported_id: check_imported_id,
        order_price: vendor.total_amount(order),
        content_description: 'opcional desc',
        n_packages: @chx_carrier ? 1 : shipment.n_packages,
        type: 'delivery',
        weight: shipping_weight,
        volume: 0.1
      }
    end

    def check_imported_id
      if shipment.enviame_carrier&.code == 'SKN'
        invoices_numbers = order&.invoices&.where(vendor_id: vendor&.id)&.pluck(:number)
        invoices_numbers.present? ? invoices_numbers.join(', ') : shipment.number
      else
        @chx_carrier ? chx_shipment_number : shipment&.number
      end
    end

    def shipping_origin_data
      {
        warehouse_code: shipment.stock_location.enviame_warehouse_code
      }
    end

    def shipping_destination_data
      {
        customer: {
          name: "#{order.ship_address.firstname} #{order.ship_address.lastname}",
          phone: order.ship_address.phone,
          email: order.email
        },
        delivery_address: {
          home_address: {
            place: order.ship_address.county&.name,
            full_address: "#{order.ship_address.address1} #{order.ship_address.street_number}, #{order.ship_address.address2}"
          }
        }
      }
    end

    def shipping_carrier_data
      {
        carrier_code: shipment.enviame_carrier_service&.code,
        carrier_service: 'normal'
      }
    end

    def generate_shipping_label
      process_request(get_delivery_url, parameters, 'delivery')
    end

    def process_request(url, args, request_type)
      url = URI(url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json'
      request['api-key'] = Rails.application.credentials.dig(@current_store_code&.to_sym, :enviame, :api_key)
      request['Content-Type'] = 'application/json'
      request.body = args.to_json
      response = https.request(request)
      parsed_data = JSON.parse(response.body)

      if response.code == '201'
        determine_response(request_type, parsed_data)
        @result = { success: true, message: "#{request_type.titleize} created!" }
      else
        @result = { success: false, message: parsed_data }
        # delivery: @result = { success: false, message: JSON.parse(response.body)['data'] }
      end
    rescue Exception => e
      @result = { success: false, message: e.message }
    end

    def process_response(data)
      response = data['data']
      link = response['links'].select { |l| l['rel'] == 'tracking-web' }

      shipment_label = shipment.shipment_labels.build

      shipment_label.assign_attributes(
        tracking_number: response['tracking_number'],
        label_url: link.first['href']
      )
      shipment_label.save!

      if response['label'] && response['label']['PDF'].present?

        pdf_html = ApplicationController.new.render_to_string(
          template: 'spree/admin/orders/enviame_label',
          locals: { shipment: shipment, order: order },
          layout: 'spree/layouts/pdf'
        )

        label_path = "#{shipment.number}-lbl.pdf"
        page_path = "#{shipment.number}-details.pdf"
        combined_file_path = "#{shipment.number}-final.pdf"

        File.open(label_path, "wb") do |file|
          file.write URI(response['label']['PDF']).open.read
        end

        File.open(page_path, 'wb') do |file|
          file.write WickedPdf.new.pdf_from_string(pdf_html, page_width: 100, page_height: 300)
        end

        pdf = CombinePDF.new
        pdf << CombinePDF.load(label_path)
        pdf << CombinePDF.load(page_path)
        pdf.save combined_file_path

        shipment_label.enviame_label.attach(io: File.open(combined_file_path), filename: "#{shipment.number}-label.pdf", content_type: 'application/pdf')

        File.delete(label_path)
        File.delete(page_path)
        File.delete(combined_file_path)
      end
    end

    def determine_response(request_type, response_data)
      case request_type
      when 'pickup'
        save_pickup_response
      when 'warehouse'
        save_warehouse_response(response_data)
      else
        process_response(response_data)
      end
    end

    def get_delivery_url
      "#{Rails.application.credentials.dig(@current_store_code&.to_sym, :enviame, :delivery_url)}/companies/#{vendor.enviame_vendor_id}/deliveries"
    end

    def warehouse_url
      "#{Rails.application.credentials.dig(@current_store_code&.to_sym, :enviame, :carriers_url)}/#{vendor.enviame_vendor_id}/warehouses"
    end

    def chx_shipment_number
      "#{shipment.number}-#{@shipment_index}"
    end
  end
end
