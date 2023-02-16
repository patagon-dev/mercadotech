module Spree
  module Admin
    module OrdersControllerDecorator
      def index
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
        params[:q][:completed_at_not_null] = '' unless @show_only_completed

        # Default showing pending shipment orders
        params[:q][:shipment_state_not_in] ||= %w[shipped canceled]

        params[:q][:shipment_state_not_in] = %w[shipped canceled] if params[:q][:shipment_state_not_in] == 'shipped'

        if params[:q][:payment_state_in].nil? || params[:q][:payment_state_in] == 'refund_pending'
          params[:q][:payment_state_in] = %w[balance_due credit_owed failed paid refund_pending]
          params[:q][:shipment_state_not_in] -= %w[canceled] if params[:q][:shipment_state_not_in].present?
        end

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == '0'

        if params[:q][:created_at_gt].present?
          params[:q][:created_at_gt] = begin
            Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
          rescue StandardError
            ''
          end
        end

        if params[:q][:created_at_lt].present?
          params[:q][:created_at_lt] = begin
            Time.zone.parse(params[:q][:created_at_lt]).end_of_day
          rescue StandardError
            ''
          end
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = Spree::Order.preload(:user).accessible_by(current_ability, :index).ransack(params[:q])

        # lazy loading other models here (via includes) may result in an invalid query
        # e.g. SELECT  DISTINCT DISTINCT "spree_orders".id, "spree_orders"."created_at" AS alias_0 FROM "spree_orders"
        # see https://github.com/spree/spree/pull/3919
        @orders = @search.result(distinct: true)
                         .page(params[:page])
                         .per(params[:per_page] || Spree::Config[:admin_orders_per_page])

        # Restore dates
        params[:q][:created_at_gt] = created_at_gt
        params[:q][:created_at_lt] = created_at_lt
      end

      def generate_pickup_list
        list_params = params[:pickup_list]

        unless list_params[:order_ids].present?
          flash[:error] = Spree.t(:are_not_selected, resource: Spree.t(:orders))
          redirect_to admin_orders_path and return
        end

        @lists = generate_pickup_or_purchased_list(list_params)

        if @lists.any?
          pdf_html = ApplicationController.new.render_to_string(
            template: 'spree/admin/orders/pickup_list',
            locals: { lists: @lists },
            layout: 'spree/layouts/pdf'
          )
          pdf = WickedPdf.new.pdf_from_string(pdf_html)
          send_data pdf, filename: "pickup_list_#{Time.now.strftime('%s')}.pdf"
        else
          flash[:error] = Spree.t(:pickup_list_not_found, resource: Spree.t(:orders))
          redirect_to admin_orders_path
        end
      end

      def generate_purchase_list
        list_params = params[:purchase_list]

        unless list_params[:order_ids].present?
          flash[:error] = Spree.t(:are_not_selected, resource: Spree.t(:orders))
          redirect_to admin_orders_path and return
        end

        @lists = generate_pickup_or_purchased_list(list_params, 'purchase')

        if @lists.any?
          pdf_html = ApplicationController.new.render_to_string(
            template: 'spree/admin/orders/purchase_list',
            locals: { lists: @lists },
            layout: 'spree/layouts/pdf'
          )
          pdf = WickedPdf.new.pdf_from_string(pdf_html)
          send_data pdf, filename: "purchase_list_#{Time.now.strftime('%s')}.pdf"
        else
          flash[:error] = Spree.t(:purchase_list_not_found, resource: Spree.t(:orders))
          redirect_to admin_orders_path
        end
      end

      def get_services
        services = Spree::EnviameCarrierService.where(enviame_carrier_id: params[:carrier_id])
        render json: { data: services.pluck(:id, :name), shipment_number: params[:shipment_number] }
      end

      def create_shipment_delivery
        shipment = Spree::Shipment.find_by(number: params[:shipment_number])
        if shipment.present?
          if params[:carrier_id] == 'moova'
            shipment.update_columns(package_size: params[:package_size].present? ? params[:package_size] : nil, n_packages: params[:n_packages]) if params[:package_size].present? || params[:n_packages].present?
            create_delivery = Moova::Shipment.new(params[:shipment_number]).create
          else
            shipment.update_columns(enviame_carrier_id: params[:carrier_id], enviame_carrier_service_id: params[:service_id], n_packages: params[:n_packages])
            create_delivery = Enviame::Delivery.new(params[:shipment_number]).create
          end
          success = create_delivery[:success]
          message = create_delivery[:message]
        else
          success = false
          message = 'Shipment not found!'
        end
        render json: { success: success, message: message.to_json }
      end

      def remove_shipping_label
        label = Spree::ShipmentLabel.find_by(id: params[:shipment_label_id])
        shipment = label&.shipment

        if label.present? && shipment.present?
          status = label.destroy
          unless shipment.shipment_labels.any?
            status = shipment.update_columns(enviame_carrier_id: nil, enviame_carrier_service_id: nil, n_packages: nil, tracking: nil, moova_shipment_id: nil)
          end
          success = status
          message = 'Successfully Removed!'
        else
          success = false
          message = 'Shipment or Label not found!'
        end
        render json: { success: success, message: message }
      end

      def mark_payment_refunded
        payment = Spree::Payment.find_by(number: params[:number])
        state = payment.amount > 0 ? 'refunded' : 'complete'
        payment.send(state)
        # order.update_column(:payment_state , 'refunded') unless order.payments.valid.refund_pending.any?
        flash[:success] = flash_message_for(payment, :successfully_updated)
        redirect_back(fallback_location: root_path)
      end

      def shipment_details
        order = Spree::Order.find_by(number: params[:id])
        return [] unless order

        @shipments = current_spree_vendor.present? ? order.shipments.where(stock_location_id: current_spree_vendor.stock_location_ids) : order.shipments
      end

      private

      def generate_pickup_or_purchased_list(params, list_type = nil)
        order_ids = params[:order_ids].split(',')
        orders = Spree::Order.accessible_by(current_ability, :index)

        orders = if order_ids.include?('all')
                   orders.where(shipment_state: params[:shipment_state])
                 else
                   orders.where(id: order_ids, shipment_state: %w[ready pickup packed])
                 end

        orders = orders.joins(shipments: [:stock_location, { inventory_units: [variant: :product] }])
        if spree_current_user.vendor?
          orders = orders.where('spree_stock_locations.vendor_id =?', spree_current_user.vendor_users.first&.vendor_id)
        end

        if list_type == 'purchase'
          lists = orders.select('spree_orders.number, spree_inventory_units.quantity as units, spree_variants.sku as item_sku, spree_products.partnumber, spree_stock_locations.name as loc_name')
                        .order(:loc_name).group_by(&:item_sku)
        else
          lists = orders.select('spree_orders.number, spree_shipments.number as ship_number, spree_inventory_units.quantity as units, spree_variants.sku as item_sku, spree_products.partnumber, spree_products.name as product_name, spree_shipments.reference_number as reference_number, spree_stock_locations.name as loc_name')
                        .group_by(&:loc_name)
        end
      end
    end
  end
end

::Spree::Admin::OrdersController.prepend Spree::Admin::OrdersControllerDecorator
