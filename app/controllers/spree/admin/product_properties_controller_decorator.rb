module Spree
  module Admin
    module ProductPropertiesControllerDecorator
      private

      def find_properties
        @properties = current_spree_vendor ? Spree::Property.where(vendor_id: current_spree_vendor.id).pluck(:name) : Spree::Property.pluck(:name)
      end
    end
  end
end

::Spree::Admin::ProductPropertiesController.prepend Spree::Admin::ProductPropertiesControllerDecorator