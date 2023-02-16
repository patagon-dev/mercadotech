module Spree
  class OneclickMallSubscriptionController < StoreController
    skip_before_action :verify_authenticity_token

    before_action :load_data
    before_action :update_rut, only: :subscribe
    include WebpayOneClickSubscription

    def subscription; end

    def subscribe
      @response_url = oneclick_mall_subscribe_confirmation_url({ order_number: @order.number })
      perform_subscription
    end

    def subscribe_confirmation
      response, message = confirm_subscription(params['TBK_TOKEN'])
      subscribe_confirmation_path = response == :success ? oneclick_mall_subscribe_success_path : oneclick_mall_subscribe_failure_path
      redirect_to subscribe_confirmation_path
    end

    def unsubscribe
      @user = @order.user
      unsubscribe_user(params['oneclick_user_id'])
      redirect_to checkout_path
    end

    def subscribe_success
      flash.now[:success] = Spree.t(:successfully_added_card)
    end

    def subscribe_failure
      flash.now[:error] = Spree.t(:failed_to_add_card)
    end

    private

    def load_data
      @order = current_order || Spree::Order.find_by(number: params['order_number']) || raise(ActiveRecord::RecordNotFound)
      @payment = @order.payments.order(:id).last
      @logger = OneclickLogger.new payment: @payment, order: @order
    end

    def update_rut
      @user = @order.user
      @username = @user.rut.present? ? @user.rut : @order.billing_address.company_rut
      @user.update_column(:rut, @username) unless @user.rut.present?
    end
  end
end
