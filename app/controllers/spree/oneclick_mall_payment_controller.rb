module Spree
  class OneclickMallPaymentController < StoreController
    skip_before_action :verify_authenticity_token
    before_action :load_data
    before_action :update_shares_number, only: [:pay]

    def pay
      unless @order.user && @order.user.webpay_oneclick_mall_users.any? && @order.user.webpay_oneclick_mall_users.subscribed.any?
        redirect_to oneclick_mall_subscription_path and return
      end

      @logger.log_info(action: 'payment.oneclick.actions.init', content: I18n.t('payment.oneclick.payment_start'))

      oneclick_user_id = params['oneclick_user_id']
      redirect_to_failure_path && return unless oneclick_user_id

      @logger.log_info(action: 'payment.oneclick.actions.oneclick_user', content: oneclick_user_id.to_s)

      begin
        response = Transbank::Webpay::Oneclick::Payment.new(@order.number, @order.webpay_amount, oneclick_user_id).run
        @logger.log_info(action: 'payment.oneclick.actions.response', content: I18n.t('payment.oneclick.auth_response', args: response.to_s))
        redirect_to_failure_path && return unless response

        @logger.log_info(action: 'payment.oneclick.actions.redirect', content: I18n.t('payment.oneclick.redirect_to_payment'))
        redirect_to oneclick_mall_success_path(order_number: @order.number)
      rescue Exception => e
        @logger.log_info(action: 'payment.oneclick.actions.failure', content: I18n.t('payment.oneclick.api_error', args: e.to_s))
        redirect_to_failure_path
      end
    end

    def success
      # To clean the cart
      session[:order_id] = nil
      @current_order     = nil

      if @order.reload.completed?
        @logger.log_info(action: 'payment.oneclick.actions.redirect', content: I18n.t('payment.oneclick.redirect_to_payment_success'))
        flash[:notice] = Spree.t(:order_processed_successfully)
        session[:tag_purchase] = @order.id
        @logger.log_info(action: 'payment.oneclick.actions.redirect', content: I18n.t('payment.oneclick.redirect_to_order_success'))
        redirect_to completion_route and return
      else
        @logger.log_info(action: 'payment.oneclick.actions.failure', content: I18n.t('payment.oneclick.order_not_completed'))
        redirect_to_failure_path and return
      end
    end

     # GET spree/webpay/failure
    def failure
      flash.now[:alert] = I18n.t('payment.transaction_error')
      @order.update(state: 'payment') if @order && !@order.payments.completed.present? # update order state
      @rejected = params[:rejected] == 'true'
    end

    private

    def load_data
      @order = current_order&.reload || Spree::Order.find_by(number: params[:order_number])
      raise(ActiveRecord::RecordNotFound) unless @order

      @payment = @order.payments.order(:id).last
      @logger = OneclickLogger.new payment: @payment, order: @order
    end

    # Same as CheckoutController#completion_route
    def completion_route
      spree.order_path(@order)
    end

    # Redirect to oneclick failure path
    def redirect_to_failure_path
      redirect_to oneclick_mall_failure_path({ order_number: @order.number })
    end

    def update_shares_number
      oneclick_user = Tbk::WebpayOneclickMall::User.find_by(id: params['oneclick_user_id'])
      return unless oneclick_user

      if params['shares_number'].present?
        if params['shares_number'].present?
          oneclick_user.update_columns(shares_number: params['shares_number'], default: true)
        end
      else
        oneclick_user.update(default: true) unless oneclick_user.default?
      end
    end
  end
end
