module Spree
  module PageEnums
    extend ActiveSupport::Concern
    included do
      enum footer_title: %w[Cliente Comunidad Empresa Otros]
    end
  end
end
