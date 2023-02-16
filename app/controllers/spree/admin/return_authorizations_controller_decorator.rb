module Spree
  module Admin
    module ReturnAuthorizationsControllerDecorator
      def index
        @return_authorizations = current_spree_vendor ? @return_authorizations.where(vendor_id: current_spree_vendor.id) : @return_authorizations
      end

      def generate_shipping_label
        unless @return_authorization.shipment_label.present?
          @label_response = Enviame::ReturnDelivery.new(@return_authorization.number).create
        end
        if @return_authorization.pending_pickup?
          @pickup_response = Enviame::Pickup.new(@return_authorization.number).create
        end
      end

      def destroy_label
        @return_authorization.shipment_label.destroy if @return_authorization.shipment_label.present?
        flash[:success] = Spree.t(:shipment_label_destroyed_successfully)
        redirect_to edit_admin_order_return_authorization_path(@return_authorization.order, @return_authorization)
      end

      private

      def load_form_data
        load_resource
        load_return_items
        load_reimbursement_types
        load_return_authorization_reasons
      end
      # Override to show vendor specific return items
      # To satisfy how nested attributes works we want to create placeholder ReturnItems for
      # any InventoryUnits that have not already been added to the ReturnAuthorization.
      def load_return_items
        all_inventory_units = current_spree_vendor ? @return_authorization.order.inventory_units.joins(:variant).where('spree_variants.vendor_id = ?', current_spree_vendor.id) : @return_authorization.order.inventory_units
        return_items = current_spree_vendor ? @return_authorization.return_items.joins(inventory_unit: :variant).where('spree_variants.vendor_id = ?', current_spree_vendor.id) : @return_authorization.return_items
        associated_inventory_units = return_items.map(&:inventory_unit)
        unassociated_inventory_units = all_inventory_units - associated_inventory_units

        new_return_items = unassociated_inventory_units.map do |new_unit|
          Spree::ReturnItem.new(inventory_unit: new_unit, return_authorization: @return_authorization).tap(&:set_default_pre_tax_amount)
        end

        @form_return_items = (@return_authorization.return_items + new_return_items).sort_by(&:inventory_unit_id)
      end
    end
  end
end

::Spree::Admin::ReturnAuthorizationsController.prepend Spree::Admin::ReturnAuthorizationsControllerDecorator
