module Spree
  module Admin
    module ProductsControllerDecorator
      def update
        params[:product][:taxon_ids] = params[:product][:taxon_ids].reject(&:empty?) if params[:product][:taxon_ids].present?
        if params[:product][:option_type_ids].present?
          params[:product][:option_type_ids] = params[:product][:option_type_ids].reject(&:empty?)
        end

        invoke_callbacks(:update, :before)
        if @object.update(permitted_resource_params)
          invoke_callbacks(:update, :after)
          flash[:success] = flash_message_for(@object, :successfully_updated)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save }
            format.js   { render layout: false }
          end
        else
          # Stops people submitting blank slugs, causing errors when they try to
          # update the product again
          @product.slug = @product.slug_was if @product.slug.blank?
          invoke_callbacks(:update, :fails)
          load_vendors
          respond_with(@object)
        end
      end

      def import_csv_products
        ImportVendorProducts.perform_later(params[:vendor_id], params[:method_name])
        flash[:success] = Spree.t(:products_are_importing_and_take_time)
        redirect_back(fallback_location: root_path)
      end

      def update_products_categories
        if params[:add_data] == 'true' && params[:taxon_ids].present?
          product_ids = params[:product_ids].split(',')
          taxon_ids = params[:taxon_ids].reject(&:empty?)
          response = bulk_update_products_categories(product_ids, taxon_ids)
        elsif params[:add_data] == 'false' && params[:taxon_ids].present?
          product_ids = params[:product_ids].split(',')
          taxon_ids = params[:taxon_ids].reject(&:empty?)
          response = if Spree::Product.where(id: product_ids).update(taxon_ids: taxon_ids)
                       { status: :success, message: Spree.t(:products_updated_successfully) }
                     else
                       { status: :error, message: Spree.t(:products_not_udpated, scope: :product_management) }
                     end
        else
          response = { status: :error, message: Spree.t(:invalid_request, scope: :product_management) }
        end
        flash[response[:status]] = response[:message]
        redirect_to admin_products_path
      end

      def stock
        super
        @variants = @product.variants.active.includes(*variant_stock_includes)
        @variants = [@product.master] if @variants.empty?
      end

      def update_products_shipping_category
        if params[:product_ids].present? && params[:selected_option].present?
          product_ids = params[:product_ids].split(',')
          response = bulk_action(product_ids, params[:selected_option], 'shipping_category')
        elsif params[:filter_params].present? && params[:selected_option].present?
          product_ids = get_all_products_ids(JSON.parse(params[:filter_params]))
          response = bulk_action(product_ids, params[:selected_option], 'shipping_category')
        else
          response = { status: :error, message: Spree.t(:product_not_found, scope: :product_management) }
        end
        flash[response[:status]] = response[:message]
        redirect_to admin_products_path
      end

      def enable_disable_products
        if params[:product_ids].present? && params[:selected_option].present?
          product_ids = params[:product_ids].split(',')
          response = bulk_action(product_ids, params[:selected_option], 'enable_disable_product')
        elsif params[:filter_params].present? && params[:selected_option].present?
          product_ids = get_all_products_ids(JSON.parse(params[:filter_params]))
          response = bulk_action(product_ids, params[:selected_option], 'enable_disable_product')
        else
          response = { status: :error, message: Spree.t(:product_not_found, scope: :product_management) }
        end
        flash[response[:status]] = response[:message]
        redirect_to admin_products_path
      end

      protected

      def load_data
        @taxons = Taxon.order(:name)
        @option_types = OptionType.order(:name)
        @tax_categories = TaxCategory.order(:name)
        @shipping_categories = ShippingCategory.accessible_by(current_ability).order(:name)
      end

      def collection
        return @collection if @collection.present?

        params[:q] ||= {}
        params[:q][:deleted_at_null] ||= '1'
        params[:q][:not_discontinued] ||= '1'

        params[:q][:s] ||= 'name asc'
        @collection = super
        # Don't delete params[:q][:deleted_at_null] here because it is used in view to check the
        # checkbox for 'q[deleted_at_null]'. This also messed with pagination when deleted_at_null is checked.
        @collection = @collection.with_deleted if params[:q][:deleted_at_null] == '0'
        # @search needs to be defined as this is passed to search_form_for
        # Temporarily remove params[:q][:deleted_at_null] from params[:q] to ransack products.
        # This is to include all products and not just deleted products.
        @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })

        # filter products on basis of stock
        filtered_results = if params[:q][:in_stock] == '1'
                             @search.result.joins(:stock_items).group('id').having('SUM(count_on_hand) > ?', 0)
                           else
                             @search.result
                           end

        @collection = filtered_results.distinct
                                      .includes(product_includes)
                                      .page(params[:page])
                                      .per(params[:per_page] || Spree::Config[:admin_products_per_page])
        @collection
      end

      def get_all_products_ids(filter_params)
        all_product = Spree::Product.accessible_by(current_ability, :index).ransack(filter_params.reject do |k, _v|
                                                                                      k.to_s == 'deleted_at_null'
                                                                                    end)
        all_product.result.any? ? all_product.result.pluck(:id) : []
      end

      def bulk_action(product_ids, selected_option_id, type)
        BulkProductUpdateJob.perform_later(product_ids, selected_option_id, type)
        { status: :success, message: Spree.t(:product_update_scheduled, scope: :product_management) }
      end

      def bulk_update_products_categories(product_ids, taxon_ids)
        products = Spree::Product.where(id: product_ids)
        products.each do |product|
          persisted_taxon_ids = product&.taxon_ids
          product.update(taxon_ids: (taxon_ids + persisted_taxon_ids).map(&:to_s).uniq)
        end
        { status: :success, message: Spree.t(:products_updated_successfully) }
      end
    end
  end
end

::Spree::Admin::ProductsController.prepend Spree::Admin::ProductsControllerDecorator
