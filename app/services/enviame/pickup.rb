require 'open-uri'

class Enviame::Pickup < Enviame::Delivery
  attr_reader :vendor, :return_authorization, :order

  def initialize(return_authorization_number)
    @return_authorization = Spree::ReturnAuthorization.find_by(number: return_authorization_number)
    @vendor = return_authorization.stock_location.vendor
    @order = return_authorization.order
    @current_store_code = @order.store&.code
  end

  def create
    generate_warehouse unless order.ship_address.customer_warehouse_code.present?
    request_pickup if order.ship_address.customer_warehouse_code.present?

    @result
  end

  private

  def parameters
    shipping_weight = return_authorization.return_items_weight
    shipping_weight = 0.1 if shipping_weight < 0.1
    quantity = return_authorization.return_items.map { |rt| rt.inventory_unit&.quantity }.compact.sum

    {
      carrier_code: 'CHX',
      warehouse_code: order.ship_address.customer_warehouse_code,
      qty: quantity,
      contact_name: order.ship_address&.firstname,
      contact_phone: order.ship_address&.phone,
      range_time: return_authorization.range_time,
      pickup_date: return_authorization.pickup_date,
      weight: shipping_weight,
      size: '',
      custom_size: ''
    }
  end

  def generate_warehouse
    process_request(warehouse_url, warehouse_parameters, 'warehouse')
  end

  def request_pickup
    process_request(pickup_url, parameters, 'pickup')
  end

  def save_warehouse_response(data)
    order.ship_address.update_column(:customer_warehouse_code, data['data']['code'])
  end

  def save_pickup_response
    return_authorization.update_column(:pickup_generated, true)
  end

  def pickup_url
    "#{Rails.application.credentials.dig(@current_store_code&.to_sym, :enviame, :delivery_url)}/companies/#{vendor.enviame_vendor_id}/pickups"
  end
end
