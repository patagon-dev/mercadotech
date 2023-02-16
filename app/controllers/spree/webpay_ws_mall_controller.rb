module Spree
  class WebpayWsMallController < StoreController
    skip_before_action :verify_authenticity_token
    before_action :load_data, only: %i[confirmation success failure]
    before_action :load_order, only: :pay

    def pay
      redirect_to_failure(action: nil, message: Spree.t(:payment_not_found)) && return unless @payment

      response = Transbank::Webpay::WebpayPlus::Payment.new(@order.number, @order.webpay_ws_mall_amount, @payment.number, @confirmation_path).init_transaction

      redirect_to_failure(action: nil, message: nil) && return unless response

      respond_to_html = Net::HTTP.post_form(URI(response.url), TBK_TOKEN: response.token)

      if respond_to_html.code == '200'
        res_body = Nokogiri::HTML.parse(respond_to_html.body)
        res_body.at('body') << Spree.t(:refresh_note_html)
        @logger.log_info(action: 'payment.actions.wi', content: I18n.t('payment.msgs.init.redirected_to_webpay'))
        respond_to do |format|
          format.html { render html: res_body.to_html.html_safe }
        end
      else
        @logger.log_info(action: 'payment.actions.wi', content: I18n.t('payment.msgs.init.not_redirected_to_webpay'))
        false
      end
    end

    def confirmation
      redirect_to completion_route and return if @order.completed?

      confirm_response = Transbank::Webpay::WebpayPlus::Payment.new(@order.number, @order.webpay_ws_mall_amount, @payment.number).get_confirmation

      redirect_to_failure(action: nil, message: nil) and return unless confirm_response

      redirect_to webpay_ws_mall_success_path(order_number: @order.number)
    end

    def success
      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil

      if @order.completed?
        @logger.log_info(action: 'payment.actions.ws', content: I18n.t('payment.msgs.success.ok_order_pay'))
        unless @order.user
          cookies.permanent.signed[:token] = cookies.permanent.signed[:guest_token] = @order.token
        end # Persisted order for guest user

        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
        session[:tag_purchase] = @order.id
        redirect_to completion_route and return
      else
        @logger.log_error(action: 'payment.actions.ws', content: I18n.t('payment.msgs.sucess.not_ok_order_pay', order_st: @order.state))
        redirect_to_failure(action: nil, message: nil) and return
      end
    end

    # GET spree/webpay/failure
    def failure
      flash.now[:alert] = I18n.t('payment.transaction_error')
      @order.update(state: 'payment') if @order && !@order.payments.completed.present?

      @rejected = params[:rejected] == 'true'
    end

    private

    def load_order
      @order = current_order&.reload || raise(ActiveRecord::RecordNotFound)
      @payment = @order.payments.valid.order(:id).last # Fetch original payment
      @confirmation_path = webpay_ws_mall_confirmation_url(order_number: @order.number)
      @logger = TbkLogger.new payment: @payment, order: @order unless defined? @logger
    end

    def load_data
      token_params = params[Tbk::WebpayWsMallCore::Constant::TBK_TOKEN] || params[Tbk::WebpayWsMallCore::Constant::TBK_FAILURE_TOKEN]
      @payment = Spree::Payment.by_webpay_ws_token(token_params) if token_params.present?

      if @payment.present? && token_params.present? # confirmation
        @order = @payment.order
      else # success or failure
        @order = Spree::Order.find_by(number: params[:order_number])
        @payment = @order.payments.order(:id).last if @order
      end

      @logger = TbkLogger.new payment: @payment, order: @order

      if @payment.nil? && params[:action] != 'failure'
        @logger.log_info(action: 'payment.actions.wc', content: I18n.t('payment.msgs.confirmation.token', token: token_params.inspect))
        redirect_to_failure(action: 'payment.actions.wc', message: I18n.t('payment.msgs.confirmation.inv_token')) and return
      end
    end

    def completion_route
      spree.order_path(@order)
    end

    def redirect_to_failure(action:, message:)
      @logger = TbkLogger.new payment: @payment, order: @order unless defined? @logger
      @logger.log_error(action: action, content: message) if action.present? && message.present?

      if @order.present?
        redirect_to webpay_ws_mall_failure_path(order_number: @order.number)
      else
        redirect_to webpay_ws_mall_failure_path
      end
    end
  end
end
