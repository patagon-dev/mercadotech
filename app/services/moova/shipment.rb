require 'open-uri'
module Moova
  class Shipment
    attr_reader :vendor, :shipment, :order, :stock_location

    def initialize(shipment_number)
      @shipment = Spree::Shipment.find_by(number: shipment_number)
      @vendor = @shipment.stock_location.vendor
      @stock_location = @shipment.stock_location
      @order = @shipment.order
    end

    def create
    shipment.n_packages.times do # for multiple shipping labels
      geocode_address
      generate_shipment

      generate_shipping_label
    end
      @result
    rescue Exception => e
      @result = { success: false, message: e.message }
    end

    private

    def parameters
      {
        currency: order.currency || Spree::Config[:currency],
        type: 'regular',
        flow: 'semi-automatic',
        from: shipping_origin_data,
        to: shipping_destination_data,
        internalCode: order.number,
        extra: {},
        conf: configurations
      }
    end

    def configurations
      {
        assurance: false,
        items: items_data
      }
    end

    def shipping_origin_data
      {
        googlePlaceId: stock_location.google_place_id,
        coords: {
          lat: stock_location.latitude,
          lng: stock_location.longitude
        },
        address: stock_location.full_address,
        country: stock_location.country.iso,
        instructions: instructions_field,
        contact: vendor_contact_data
      }
    end

    def vendor_contact_data
      {
        firstName: vendor.name,
        lastName: '',
        email: stock_location.notification_email || vendor.notification_email,
        phone: stock_location.phone || vendor.phone
      }
    end

    def shipping_destination_data
      address = order.shipping_address
      data = {
        street: address.address1,
        number: address.street_number,
        floor: '',
        apartment: address.address2,
        city: address.county&.name || address&.city,
        state: address.state&.name,
        country: address.country&.iso,
        instructions: instructions_field,
        contact: contact_dist_data(address),
        message: ''
      }

      @google_place_id.present? ? data.merge!({ googlePlaceId: @google_place_id }) : data
      @coordinates.present? ? data.merge!({ coords: @coordinates }) : data
      data
    end

    def contact_dist_data(address)
      {
        firstName: address.firstname,
        lastName: address.lastname,
        email: (order.user&.email || order.email),
        phone: '+569' + address.phone.to_s
      }
    end

    def items_data
      package_size = shipment.package_size

      shipment.line_items.map do |line_item|
        {
          item: load_item(line_item, package_size)
        }
      end
    end

    def load_item(line_item, package_type)
      variant = line_item.variant

      case package_type
      when "EXTRASMALL"
        { description: line_item.name, price: line_item.price.to_f, weight: (2*1000).to_f, length: (34).to_f, width: (24).to_f, height: (4).to_f }
      when "SMALL"
        { description: line_item.name, price: line_item.price.to_f, weight: (4*1000).to_f, length: (39).to_f, width: (29).to_f, height: (14).to_f }
      when "MEDIUM"
        { description: line_item.name, price: line_item.price.to_f, weight: (13*1000).to_f, length: (54).to_f, width: (44).to_f, height: (29).to_f }
      when "LARGE"
        { description: line_item.name, price: line_item.price.to_f, weight: (30*1000).to_f, length: (99).to_f, width: (74).to_f, height: (49).to_f }
      when "EXTRALARGE"
        { description: line_item.name, price: line_item.price.to_f, weight: (45*1000).to_f, length: (170).to_f, width: (80).to_f, height: (69).to_f }
      else
        { description: line_item.name, price: line_item.price.to_f, weight: variant.weight.to_f, length: variant.depth.to_f, width: variant.width.to_f, height: variant.height.to_f }
      end
    end

    def generate_shipment
      response = process_request(shipping_url, 'POST', true)

      if response.code == '201'
        parsed_data = JSON.parse(response.body)
        shipment.update(moova_shipment_id: parsed_data['id'])
      else
        @result = { success: false, message: JSON.parse(response.body)['message'] }
        return @result
      end
    end

    def process_request(request_url, req_method, req_params)
      url = URI(request_url)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = req_method == 'GET' ? Net::HTTP::Get.new(url) : Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json'
      request['Authorization'] = moova_secret_key
      request['Content-Type'] = 'application/json'
      request.body = parameters.to_json if req_params
      https.request(request)
    end

    def generate_shipping_label
      if shipment.moova_shipment_id
        response = process_request(shipping_label_url(shipment.moova_shipment_id), 'GET', false)
        parsed_data = JSON.parse(response.body)

        if response.code == '200' && parsed_data['label'].present?
          attach_pdf_document(parsed_data['label'])
        else
          @result = { success: false, message: parsed_data['message'] }
        end
      else
        @result = { success: false, message: Spree.t(:moova_shipping_id_not_found) }
      end
    end

    def attach_pdf_document(label)
      shipment_label = shipment.shipment_labels.build
      shipment_label.assign_attributes(
        tracking_number: shipment.moova_shipment_id.split('-')[0],
        label_url: tracking_url
      )
      shipment_label.save!

      pdf_html = ApplicationController.new.render_to_string(
        template: 'spree/admin/orders/enviame_label',
        locals: { shipment: shipment, order: order },
        layout: 'spree/layouts/pdf'
      )

      label_path = "#{shipment.number}-lbl.pdf"
      page_path = "#{shipment.number}-details.pdf"
      combined_file_path = "#{shipment.number}-final.pdf"

      File.open(label_path, 'wb') do |file|
        file.write URI.open(label).read
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

      @result = { success: true, message: 'Shipping label successfully generated!' }
    end

    def geocode_address
      @coordinates = {}

      url = URI(shipping_address_url)
      params = { address: parse_address, key: Rails.application.credentials.dig(:google, :api_key) }
      url.query = URI.encode_www_form(params)
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      response = https.request(request)
      if response && response.code == '200'
        parsed_response = JSON.parse(response.body)
        location = parsed_response['results'][0]['geometry']['location']
        @google_place_id = parsed_response['results'][0]['place_id']
        @coordinates = {
          lat: location['lat'],
          lng: location['lng']
        }
      else
        @result = { success: false, message: Spree.t(:geocode_address_not_found) }
        return @result
      end
    end

    def parse_address
      ship_address = order.ship_address
      "#{ship_address.address1} #{ship_address.street_number},#{ship_address.county.name},#{ship_address.state.name}"
    end

    def shipping_url
      "#{Rails.application.credentials.dig(:moova, :delivery_url)}?appId=#{moova_app_id}"
    end

    def shipping_label_url(shipping_id)
      "#{Rails.application.credentials.dig(:moova, :delivery_url)}/#{shipping_id}/label/?appId=#{moova_app_id}"
    end

    def tracking_url
      "#{Rails.application.credentials.dig(:moova, :dashboard)}/external/#{shipment.moova_shipment_id}"
    end

    def shipping_address_url
      Rails.application.credentials.dig(:google, :geocoding_api_url)
    end

    def instructions_field
      ship_address = order.ship_address
      "#{ship_address.address1} #{ship_address.street_number}, #{ship_address.address2}, #{ship_address.county&.name}"
    end

    def moova_app_id
      vendor&.moova_api_key.present? ? vendor&.moova_api_key : Rails.application.credentials.dig(:moova, :app_id)
    end

    def moova_secret_key
      vendor&.moova_api_secret.present? ? vendor&.moova_api_secret : Rails.application.credentials.dig(:moova, :secret_key)
    end
  end
end
