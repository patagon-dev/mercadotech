require 'net/http'

class Payment::MicroCompra
  PURCHASE_URL = 'https://administradordeserviciosapi.azure-api.net/MicroCompra/RegistroDeCompra'.freeze

  def self.purchase!(_amount, _transaction_details, options = {})
    @order = Spree::Order.find_by(number: options[:order_id].split('-')[0])

    vendor_line_items = @order.line_items.includes(:product).group_by { |x| x.product.vendor}

    vendor_line_items.each do |vendor, items|
      params = params(vendor, @order, items)
      response = register_order(params, vendor)
    end
  end

  def self.register_order(body, vendor)
    uri = URI(PURCHASE_URL)

    request = Net::HTTP::Post.new(uri.request_uri)

    request['Content-Type'] = 'application/json'

    request.body = body.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    response = JSON.parse(response.body)
    @order.micro_compra_purchase_orders.create(fecha_respuesta: response['FechaRespuesta'], codigo_respuesta: response['CodigoRespuesta'], respuesta: response['Respuesta'], url: response['Url'], vendor_id: vendor.id, status: response['CodigoRespuesta'] == 1 ? 0 : 1)
  end

  def self.params(vendor, order, items)
    {
      "idTienda": vendor.ticket_id,
      "CodigoCompra": order.number,
      "RutProveedor": vendor.rut,
      "RazonSocialProveedor": vendor.name,
      "DireccionProveedor": vendor.address,
      "RutComprador": order.user&.rut,
      "CodigoUsuario": order.user&.codigo,
      "CodigoUsuarioTienda": order.user&.id,
      "FechaCompra": Time.now.strftime('%F %T'),
      "MontoTotal": vendor.total_amount(order),
      "MonedaCompra": 'CLP',
      "DireccionDespacho": order.user&.ship_address&.address1,
      "FechaEntrega": '',
      "productos": items.map { |item| { "TipoCodigoProducto": 'SKU', "CodigoProducto": item.sku, "NombreProducto": item.name, "CantidadProducto": item.quantity, "PrecioUnitario": item.price.to_i, "Informacion": item.description }}
    }
  end
end
