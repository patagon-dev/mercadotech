module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :check_site_on_maintenance
      base.before_action :ensure_vendors_minimum_order_value, :remove_webpay_ws_mall_state_if_invalid, :ensure_active_vendor_items, only: [:edit]
    end

    # Updates the order and advances to the next state (when possible.)
    def update
      newsletter_subscription if params[:newsletter].present?
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to determine_route(@order.state)
        end
      else
        render :edit
      end
    end

    private

    def ensure_active_vendor_items
      inactive_vendors = @order.get_vendors.where.not(state: 'active')
      return true unless inactive_vendors

      if inactive_vendors.any?
        inactive_line_items = @order.line_items.joins(:product).where('spree_products.vendor_id IN (?)', inactive_vendors.pluck(:id))
        flash[:error] = inactive_line_items.map(&:name).join(', ') << ' : ' << Spree.t(:you_have_unactive_vendors_product)
        redirect_to(spree.cart_path)
      end
    end

    def add_store_credit_payments
      if params.key?(:apply_store_credit) && verified_purchase_orders?

        # Create customer purchase orders specific to vendors
        if params[:purchase_order].present?
          params[:purchase_order].each do |purchase_order|
            @order.customer_purchase_orders.create(purchase_order.permit!)
          end
        end

        add_store_credit_service.call(order: @order)

        # Remove other payment method parameters.
        params[:order].delete(:payments_attributes)
        params[:order].delete(:existing_card)
        params.delete(:payment_source)

        # Return to the Payments page if additional payment is needed.
        redirect_to checkout_state_path(@order.state) and return if @order.payments.valid.sum(:amount) < @order.total
      end
    end

    def remove_webpay_ws_mall_state_if_invalid
      if @order.has_webpay_ws_mall_payment_method? || @order.has_oneclick_mall_payment_method?
        @order.payments.valid.map(&:invalidate!)
        @order.update(state: 'payment') if [Spree::Gateway::WebpayWsMall.STATE, Spree::Gateway::WebpayOneclickMall.STATE].include?(@order.state)
      end
    end

    def ensure_vendors_minimum_order_value
      vendors = @order.get_vendors.where(set_minimum_order: true)
      if vendors.any? { |vendor| vendor.total_amount(@order) < vendor.minimum_order_value }

        error_msg = vendors.map do |vendor|
          [Spree.t(:failed_minimum_order_criteria, name: vendor.name, amount: vendor.display_minimum_order_value)]
        end.join(' ')

        flash[:error] = error_msg
        redirect_to(cart_path) && return
      else
        true
      end
    end

    def determine_route(state)
      case state
      when Spree::Gateway::WebpayWsMall.STATE
        webpay_ws_mall_path({state: state}) #webpay
      when Spree::Gateway::WebpayOneclickMall.STATE #webpay oneclick
        oneclick_mall_pay_path(permitted_params.merge(oneclick_user_id: params['oneclick_user_id']))
      else
        checkout_state_path(state)
      end
    end

    def check_site_on_maintenance
      redirect_to(cart_path) && return if current_store.maintenance_mode
    end

    def verified_purchase_orders?
      max_length = Spree::CustomerPurchaseOrder::MAX_LENGTH
      return true unless params[:purchase_order].any? { |o| o['purchase_order_number'].length > max_length }

      flash[:error] = Spree.t('errors.messages.too_long', max_length: max_length)
      redirect_to(checkout_state_path(@order.state)) && return
    end

    def permitted_params
      params.permit!
    end

    def newsletter_subscription
      if @order.present?
        list_key = @order.store&.lists&.default&.take&.key
        email = @order.email

        NewsletterSubscriptionJob.perform_now(list_key, email, current_store.code)
      end
    end
  end
end

::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
