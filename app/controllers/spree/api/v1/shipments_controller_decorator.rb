module Spree
  module Api
    module V1
      module ShipmentsControllerDecorator
        def self.prepended(base)
          base.before_action :find_and_update_shipment, only: %i[ship ready add remove update_state]
        end

        def update_state
          authorize! :update, @shipment, params[:token]
          @shipment.send(shipment_params[:state]) if shipment_params[:state].present?
          respond_with(@shipment, default_template: :show)
        end
      end
    end
  end
end

::Spree::Api::V1::ShipmentsController.prepend Spree::Api::V1::ShipmentsControllerDecorator
