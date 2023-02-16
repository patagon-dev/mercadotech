module WebpayOneClickSubscription
  extend ActiveSupport::Concern

  def perform_subscription
    @logger.log_info(action: 'payment.oneclick.actions.subscribe', content: I18n.t('payment.oneclick.subscription_start'))

    begin
      init_subscription = Transbank::Webpay::Oneclick::MallInscription.start(user_name: @username, email: @user.email, response_url: @response_url)
      @logger.log_info(action: 'payment.oneclick.actions.response', content: I18n.t('payment.oneclick.init_response', args: init_subscription.inspect.to_s))
    rescue Exception => e
      @logger.log_info(action: 'payment.oneclick.actions.failure', content: I18n.t('payment.oneclick.api_error', args: e.to_s))
      redirect_to oneclick_mall_subscribe_failure_path && return
    end

    if init_subscription.url_webpay && init_subscription.token
      @logger.log_info(action: 'payment.oneclick.actions.oneclick_user', content: I18n.t('payment.oneclick.user_create'))
      oneclick_user = @user.webpay_oneclick_mall_users.find_or_initialize_by(token: init_subscription.token)
      oneclick_user.subscribed = false if oneclick_user.persisted?
      oneclick_user.save

      args = { TBK_TOKEN: init_subscription.token }
      webpay_url = "#{init_subscription.url_webpay}?#{args.to_query}"
      @logger.log_info(action: 'payment.oneclick.actions.redirect', content: I18n.t('payment.oneclick.redirect_to_sub_confirm'))
      redirect_to webpay_url
    else
      @logger.log_info(action: 'payment.oneclick.actions.oneclick_user', content: I18n.t('payment.oneclick.user_not_found'))
      redirect_to oneclick_mall_subscribe_failure_path
    end
  end

  def confirm_subscription(tbk_token)
    @logger.log_info(action: 'payment.oneclick.actions.redirect', content: I18n.t('payment.oneclick.subscribe_confirmation'))
    oneclick_user = Tbk::WebpayOneclickMall::User.find_by(token: tbk_token)

    if oneclick_user
      begin
        finish_inscription = Transbank::Webpay::Oneclick::MallInscription.finish(token: tbk_token)
        @logger.log_info(action: 'payment.oneclick.actions.response', content: I18n.t('payment.oneclick.finish_response', args: finish_inscription.inspect.to_s))
      rescue Exception => e
        response = :error
        message = Spree.t(:failed_to_add_card)
        return redirect_to_failure_path(e, response, message)
      end

      unless finish_inscription.response_code.eql?(0)
        return redirect_to_failure_path("response_code: #{finish_inscription.response_code}", :error, Spree.t(:failed_to_add_card))
      end

      oneclick_user.update(finish_inscription.instance_values.except('response_code').merge(subscribed: true))
      @logger.log_info(action: 'payment.oneclick.actions.redirect', content: I18n.t('payment.oneclick.redirect_to_sub_confirm_success'))
      response = :success
      message = Spree.t(:successfully_added_card)
      [response, message]
    else
      @logger.log_info(action: 'payment.oneclick.actions.subscribe_confirmation', content: I18n.t('payment.oneclick.user_not_found'))
      raise(ActiveRecord::RecordNotFound)
    end
  end

  def unsubscribe_user(oneclick_user_id)
    redirect_to root_path and return unless @user

    webpay_oneclick_mall_user = @user.webpay_oneclick_mall_users.find_by(id: oneclick_user_id)

    if webpay_oneclick_mall_user && webpay_oneclick_mall_user.subscribed?
      begin
        unsubscribe = Transbank::Webpay::Oneclick::MallInscription.delete(tbk_user: webpay_oneclick_mall_user.tbk_user, user_name: @user.rut)
        @logger.log_info(action: 'payment.oneclick.actions.response', content: I18n.t('payment.oneclick.unsubscribe_response', args: unsubscribe.inspect.to_s))
      rescue Exception => e
        response = :error
        message = Spree.t(:failed_to_destroy_card)
        return redirect_to_failure_path(e, response, message)
      end

      if unsubscribe.status == 'OK' && webpay_oneclick_mall_user.destroy
        response = :success
        message = Spree.t(:successfully_destroyed_card)
      else
        response = :error
        message = Spree.t(:failed_to_destroy_card)
      end
      [response, message]
    else
      response = :error
      message = Spree.t(:failed_to_destroy_card)
      [response, message]
    end
  end

  private

  def redirect_to_failure_path(error, response, message)
    @logger.log_info(action: 'payment.oneclick.actions.failure', content: I18n.t('payment.oneclick.api_error', args: error.to_s))
    [response, message]
  end
end
