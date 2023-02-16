module Spree
  module ShipmentEnums
    extend ActiveSupport::Concern
    included do
      enum package_size: %w[EXTRASMALL SMALL MEDIUM LARGE EXTRALARGE]
    end
  end
end
