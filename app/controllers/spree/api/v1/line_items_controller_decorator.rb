module Spree
  module Api
    module V1
      module LineItemsControllerDecorator
        private

        def line_items_attributes
          { line_items_attributes: {
            id: params[:id],
            quantity: params[:line_item][:quantity],
            custom_price: params[:line_item][:custom_price],
            options: line_item_params[:options] || {}
          } }
        end

        def line_item_params
          params.require(:line_item).permit(:quantity, :custom_price, :variant_id, options: line_item_options)
        end
      end
    end
  end
end

::Spree::Api::V1::LineItemsController.prepend Spree::Api::V1::LineItemsControllerDecorator
