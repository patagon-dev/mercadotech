module Spree
  module VendorEnums
    extend ActiveSupport::Concern
    included do
      enum invoice_options: %w[manual_upload superfactura_api]
      enum import_options: %w[files scrapinghub]
    end
  end
end
