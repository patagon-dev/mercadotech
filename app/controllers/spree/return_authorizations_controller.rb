module Spree
  class ReturnAuthorizationsController < StoreController
    before_action :redirect_unauthorized_access, unless: :spree_current_user
    before_action :load_order, only: %i[new create show]
    before_action :load_return_authorization, only: :show
    before_action :load_form_data, only: :show

    def new
      @return_authorization = @order.return_authorizations.build
      load_form_data
    end

    def create
      selected_return_item_params = create_return_authorization_params[:return_items_attributes].select { |_key, value| value[:_destroy] == '0' }
      @grouped_items = Hash.new { |h, k| h[k] = [] }

      selected_return_item_params.each do |index, item_params|
        inventory_unit = Spree::InventoryUnit.find_by(id: item_params[:inventory_unit_id])
        @grouped_items[inventory_unit.variant.vendor] << index if inventory_unit
      end

      create_vendor_return_authorizations

      respond_to do |format|
        format.html do
          if @success
            flash[:success] = Spree.t(:successfully_created, resource: 'Item return')
            redirect_to account_path
          else
            flash.now[:error] = Spree.t(:something_went_wrong)
            redirect_to new_order_return_authorization_path
          end
        end
      end
    end

    private

    def create_return_authorization_params
      return_authorization_params.merge(user_initiated: true)
    end

    def load_form_data
      load_return_items
      load_return_authorization_reasons
    end

    # To satisfy how nested attributes works we want to create placeholder ReturnItems for
    # any InventoryUnits that have not already been added to the ReturnAuthorization.
    def load_return_items
      all_inventory_units = @order.inventory_units.shipped
      associated_inventory_units = @return_authorization.return_items.map(&:inventory_unit)
      unassociated_inventory_units = all_inventory_units - associated_inventory_units

      new_return_items = unassociated_inventory_units.map do |new_unit|
        @return_authorization.return_items.build(inventory_unit: new_unit)&.tap(&:set_default_pre_tax_amount)
      end

      @form_return_items = (@return_authorization.return_items + new_return_items).sort_by(&:inventory_unit_id).uniq
    end

    def load_return_authorization_reasons
      @return_authorization_reasons = Spree::ReturnAuthorizationReason.active
    end

    def load_order
      @order = spree_current_user.orders.returned.find_by(number: params[:order_id])

      unless @order
        flash[:error] = Spree.t('order_not_found')
        redirect_to account_path
      end
    end

    def load_return_authorization
      @return_authorization = @order.return_authorizations.find_by(number: params[:id])

      unless @return_authorization
        flash[:error] = Spree.t('return_authorizations_controller.return_authorization_not_found')
        redirect_to account_path
      end
    end

    def create_vendor_return_authorizations
      @grouped_items.each do |vendor, item_indices|
        stock_location_id = vendor.stock_locations.rma_default.take&.id
        next unless stock_location_id

        new_params = create_return_authorization_params.dup
        new_params[:return_items_attributes] = new_params[:return_items_attributes].select { |key, _| item_indices.include?(key) }
        ra = @order.return_authorizations.build(new_params)
        ra.stock_location_id = stock_location_id
        ra.vendor_id = vendor.id
        @success = ra.save ? true : false
      end
    end

    def return_authorization_params
      params.require(:return_authorization).permit(:request_pickup, :range_time, :pickup_date, :return_authorization_reason_id, :memo, return_items_attributes: %i[inventory_unit_id _destroy exchange_variant_id return_quantity pre_tax_amount])
    end
  end
end
