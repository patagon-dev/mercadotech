module Spree
  module UsersControllerDecorator
    def self.prepended(base)
      base.before_action :verify_authenticity_token, except: %i[card_subscription card_subscription_confirmation card_unsubscription]
      base.before_action :load_user, only: %i[card_subscription card_unsubscription card_subscription_confirmation]
      base.before_action :update_rut, only: :card_subscription
      base.before_action :display_message, only: :show
      base.include WebpayOneClickSubscription
    end

    def card_subscription
      @response_url = spree.card_subscription_confirmation_url
      perform_subscription
    end

    def card_subscription_confirmation
      response, message = confirm_subscription(params['TBK_TOKEN'])
      cookies['oneclick'] = message
      redirect_to spree.account_path
    end

    def card_unsubscription
      response, message = unsubscribe_user(params['oneclick_user_id'])
      cookies['oneclick'] = message
      redirect_to spree.account_path
    end

    def display_message
      if cookies['oneclick'].present?
        flash.now[:notice] = cookies['oneclick']
        cookies.delete('oneclick')
      end
    end

    def update_card
      return unless params['oneclick_user_id'].present?

      oneclick_user = Tbk::WebpayOneclickMall::User.find_by(id: params['oneclick_user_id'])
      oneclick_user.update(shares_number: params['shares_number'], default: params['oneclick_default'])

      flash[:success] = Spree.t('oneclick_card_update')
      redirect_to spree.account_path
    end

    private

    def load_user
      @user ||= try_spree_current_user
      @logger = OneclickLogger.new(payment: nil, order: nil)
    end

    def update_rut
      @username = @user.rut.present? ? @user.rut : params['subscribe']['rut']
      return if @user.rut.present?

      unless @user.update(rut: @username)
        flash[:error] = @user.errors.full_messages.join(', ')
        redirect_to spree.account_url and return
      end
    end
  end
end

::Spree::UsersController.prepend Spree::UsersControllerDecorator
