module Spree
  module Admin
    module ReturnIndexControllerDecorator
      private

      # Override to show vendor specific resource
      def collection(resource)
        return @collection if @collection.present?

        params[:q] ||= {}

        @collection = current_spree_vendor ? resource.joins(return_items: [inventory_unit: :variant]).where('spree_variants.vendor_id = ?', current_spree_vendor.id) : resource.all
        # @search needs to be defined as this is passed to search_form_for
        @search = @collection.ransack(params[:q])
        per_page = params[:per_page] || Spree::Config[:admin_customer_returns_per_page]
        @collection = @search.result.order(created_at: :desc).page(params[:page]).per(per_page)
      end
    end
  end
end

::Spree::Admin::ReturnIndexController.prepend Spree::Admin::ReturnIndexControllerDecorator
