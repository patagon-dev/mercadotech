class Enviame::ReturnDelivery < Enviame::Delivery
  attr_reader :return_authorization, :stock_location

  def initialize(return_authorization_number)
    @return_authorization = Spree::ReturnAuthorization.find_by(number: return_authorization_number)
    @stock_location = return_authorization.stock_location
    @vendor = stock_location.vendor
    @order = return_authorization.order
    @current_store_code = @order.store&.code
  end

  def create
    generate_warehouse unless order.ship_address.customer_warehouse_code.present?
    generate_shipping_label
    @result
  end

  protected

  def shipping_order_data
    shipping_weight = return_authorization.return_items_weight
    shipping_weight = 0.1 if shipping_weight < 0.1
    {
      imported_id: return_authorization.number,
      order_price: return_authorization.pre_tax_total,
      content_description: 'opcional desc',
      n_packages: 1,
      type: 'delivery',
      weight: shipping_weight,
      volume: 0.1
    }
  end

  # Customer warehouse code
  def shipping_origin_data
    {
      warehouse_code: order.ship_address.customer_warehouse_code
    }
  end

  # Stock Location Address
  def shipping_destination_data
    {
      customer: {
        name: stock_location.name,
        phone: stock_location.phone
      },
      delivery_address: {
        home_address: {
          place: stock_location.city,
          full_address: stock_location.full_address
        }
      }
    }
  end

  def shipping_carrier_data
    {
      carrier_code: Rails.env.production? ? 'CHX_PETA' : 'CHX',
      carrier_service: 'normal'
    }
  end

  def generate_warehouse
    process_request(warehouse_url, warehouse_parameters, 'warehouse')
  end

  def save_warehouse_response(data)
    order.ship_address.update_column(:customer_warehouse_code, data['data']['code'])
  end

  def process_response(data)
    response = data['data']
    link = response['links'].select { |l| l['rel'] == 'tracking-web' }

    shipment_label = Spree::ShipmentLabel.new(
      tracking_number: response['tracking_number'],
      label_url: link.first['href'],
      return_authorization_id: return_authorization.id
    )
    shipment_label.save!

    if response['label'] && response['label']['PDF'].present?
      label_path = "#{return_authorization.number}-lbl.pdf"

      File.open(label_path, "wb") do |file|
        file.write URI(response['label']['PDF']).open.read
      end

      shipment_label.enviame_label.attach(io: File.open(label_path), filename: "#{return_authorization.number}-label.pdf", content_type: "application/pdf")

      # Send notification to customer about return shipping label
      if shipment_label.enviame_label.attached?
        Spree::ShipmentMailer.return_shipping_label_notification(order.id, shipment_label.enviame_label.blob).deliver_later
      end

      File.delete(label_path)
    end
  end
end
