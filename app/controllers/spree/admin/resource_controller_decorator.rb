module Spree
  module Admin
    module ResourceControllerDecorator
      def self.prepended(base)
        base.before_action :load_resource, except: %i[update_positions import_csv_modal import_csv_products update_categories_modal update_products_categories update_shipping_category_modal enable_disable_products_modal update_products_shipping_category enable_disable_products]
      end
    end
  end
end

::Spree::Admin::ResourceController.prepend Spree::Admin::ResourceControllerDecorator
