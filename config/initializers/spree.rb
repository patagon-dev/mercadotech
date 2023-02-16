# Configure Spree Preferences

require 'spree/app_configuration_decorator'
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# Note: If a preference is set here it will be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will not make the preference value go away.
#       Instead you must either set a new value or remove entry, clear cache, and remove database entry.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree::Money.default_formatting_rules[:thousands_separator] = '.'

Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  config.track_inventory_levels = true
  config.currency = 'CLP'
  config.allow_guest_checkout = true
  config.products_per_page = 21
  config.admin_interface_logo = 'admin_logo.png'
  country = begin
    Spree::Country.find_by_name('Chile')
  rescue StandardError
    nil
  end
  config.admin_orders_per_page = 60
  if country.present?
    country.update(zipcode_required: false)
    config.default_country_id = country.id
  end

  config.searcher_class = Spree::Search::Searchkick
end

# Configure Spree Dependencies
#
# Note: If a dependency is set here it will NOT be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will make the dependency value go away.
#
Spree.dependencies do |dependencies|
  # Example:
  # Uncomment to change the default Service handling adding Items to Cart
  # dependencies.cart_add_item_service = 'MyNewAwesomeService'
  dependencies.checkout_add_store_credit_service = 'Spree::Checkout::CustomStoreCredit'
end

Spree.user_class = 'Spree::User'

Spree::Config[:company] = true

Spree::PermittedAttributes.user_attributes << %i[rut codigo nombres apellidos telefono celular organismo rut_unidad use_billing store_ids]
Spree::PermittedAttributes.address_attributes << %i[unidad company_rut company_business street_number e_rut purchase_order_number document_type county_id address]
Spree::PermittedAttributes.vendor_attributes << %i[rut ticket_id address webpay_ws_mall_store_code phone products_csv_url products_xml_url invoice_options superfactura_login superfactura_password superfactura_environment enable_khipu khipu_id khipu_secret enviame_vendor_id import_store_ids import_options scrapinghub_api_key scrapinghub_project_id full_spider quick_spider set_minimum_order minimum_order_value enable_moova moova_api_key moova_api_secret enable_bank_transfer bank_transfer_url bank_transfer_login bank_transfer_password]
Spree::PermittedAttributes.payment_attributes << :vendor_id
Spree::PermittedAttributes.checkout_attributes << :reference_order_numbers
Spree::PermittedAttributes.product_attributes << :store_ids
Spree::PermittedAttributes.shipment_attributes << %i[reference_number state]
Spree::PermittedAttributes.customer_return_attributes << %i[vendor_id]
Spree::PermittedAttributes.stock_location_attributes << %i[notification_email]

Rails.application.config.spree.payment_methods << Spree::Gateway::MicroCompra
Rails.application.config.spree.payment_methods << Spree::Gateway::WebpayWsMall
Rails.application.config.spree.payment_methods << Spree::Gateway::WebpayOneclickMall
Rails.application.config.spree.payment_methods << Spree::Gateway::WireTransfer

SpreeSocial::OAUTH_PROVIDERS << %w[OpenIdConnect openid_connect true]
SpreeSocial::OAUTH_PROVIDERS << %w[Standard standard true]

Searchkick.client = Elasticsearch::Client.new host: Rails.application.credentials[:elasticsearch_host]
Searchkick.index_prefix = Spree::Config[:instance_index_key]
