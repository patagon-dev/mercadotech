require 'net/http'
class ImportUsers
  def initialize
    @country_id = Spree::Config[:default_country_id]
  end

  def run
    uri = URI(import_url)

    request = Net::HTTP::Get.new(uri.request_uri)

    request.body = '{body}'

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    response =  JSON.parse(response.body)

    customers = response['UsuariosMicrocompra']

    customers.each do |customer|
      user = Spree::User.where(rut: Rut.formatear(customer['Rut'])).first
      next unless user && !user.bill_address_id?

      user.build_bill_address(address_attributes(customer, user.id))
      user.ship_address = user.bill_address
      user.save(validate: false)
    end
  end

  def address_attributes(customer, user_id)
    {
      firstname: customer['Nombres'],
      lastname: customer['Apellidos'],
      address1: customer['Direccion'],
      city: customer['citName'],
      state_name: customer['disName'],
      phone: customer['Telefono'],
      unidad: customer['Unidad'],
      country_id: @country_id,
      user_id: user_id
    }
  end

  private

  def import_url
    if Rails.env.production?
      'https://apis.mercadopublico.cl/MicroCompra/UsuariosMicrocompra.json?ticket=B107671D-DDA6-4491-826A-0C82452AD074'
    else
      'https://administradordeserviciosapi.azure-api.net/MicroCompra/ListadoUsuarios.json?ticket=3595CBF4-046A-4C22-8E83-B23CF76325E3'
    end
  end

  def user_attributes(customer)
    {
      email: customer['Correo'],
      rut: customer['Rut'],
      codigo: customer['Codigo'],
      nombres: customer['Nombres'],
      apellidos: customer['Apellidos'],
      telefono: customer['Telefono'],
      celular: customer['Celular']
    }
  end
end
