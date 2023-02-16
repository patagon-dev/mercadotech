module Spree
  module Admin
    module VariantsControllerDecorator
      protected

      def collection
        super
        @collection.active
      end

      private

      def redirect_on_empty_option_values
        @product = Spree::Product.find_by(slug: params[:product_id]) if params[:product_id].present?
        redirect_to admin_product_variants_url(params[:product_id]) if @product.empty_option_values?
      end
    end
  end
end

Spree::Admin::VariantsController.prepend Spree::Admin::VariantsControllerDecorator