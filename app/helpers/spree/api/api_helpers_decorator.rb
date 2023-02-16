module Spree
  module Api
    module ApiHelpersDecorator
      Spree::Api::ApiHelpers.shipment_attributes << :reference_number unless Spree::Api::ApiHelpers.shipment_attributes.include?(:reference_number)
      Spree::Api::ApiHelpers.address_attributes.push(:company_rut, :street_number)
      Spree::Api::ApiHelpers.vendor_attributes.push(:scrapinghub_project_id, :rut, :notification_email, :full_spider, :quick_spider)
      Spree::Api::ApiHelpers.stock_location_attributes << :admin_name unless Spree::Api::ApiHelpers.stock_location_attributes.include?(:admin_name)
      Spree::Api::ApiHelpers.payment_attributes << :vendor_id unless Spree::Api::ApiHelpers.payment_attributes.include?(:vendor_id)
    end
  end
end

::Spree::Api::ApiHelpers.prepend Spree::Api::ApiHelpersDecorator
