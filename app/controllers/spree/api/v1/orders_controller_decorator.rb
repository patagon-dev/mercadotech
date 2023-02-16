module Spree
  module Api
    module V1
      module OrdersControllerDecorator
        def update_reference_numbers
          authorize! :update, @order, params[:token]
          if @order.update(order_params)
            respond_with(@order, default_template: :order_reference_numbers)
          else
            invalid_resource!(@order)
          end
        end

        def index
          authorize! :index, Order
          @orders = Order.accessible_by(current_ability, :index).ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@orders)
        end
      end
    end
  end
end

::Spree::Api::V1::OrdersController.prepend Spree::Api::V1::OrdersControllerDecorator
