module Spree
  module Api
    module V1
      module ProductsControllerDecorator

        def active_products
          if current_store.present?
            @products =  current_store.products&.active

            @products = @products.distinct.page(params[:page]).per(params[:per_page])
            expires_in 15.minutes, public: true
            headers['Surrogate-Control'] = "max-age=#{15.minutes}"
            respond_with(@products)
          else
            not_found
            return
          end
        end

      end
    end
  end
end

::Spree::Api::V1::ProductsController.prepend Spree::Api::V1::ProductsControllerDecorator