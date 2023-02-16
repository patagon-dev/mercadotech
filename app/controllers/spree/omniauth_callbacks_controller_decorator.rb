module Spree
  module OmniauthCallbacksControllerDecorator
    def openid_connect
      if request.env['omniauth.error'].present?
        flash[:error] = I18n.t('devise.omniauth_callbacks.failure', kind: auth_hash['provider'], reason: Spree.t(:user_was_not_valid))
        redirect_back_or_default(root_url)
        return
      end

      # Customization: ClaveUnica response "numero": 55555555, "DV": "5" (which means VAT ID 55.555.555-5)
      # Allow customers to login with matched VAT ID from database
      # auth_hash['extra']['raw_info']['RolUnico']['numero'] - 44444444
      # auth_hash['extra']['raw_info']['RolUnico']['DV'] - 4
      ## Database Users RUT field has different formats
      # VAT ID has different display. For example, my VAT ID (RUT) is "10268889-9", but it is also common to show it as "10.268.889-9" or even "102688899".
      # The last characther is a verification digit, which can have any value between 0 and 9, but also can be a "K" or "k" letter.
      # In my case, the verification digit of my RUT is "9", but, for example, this VAT ID: "16607830-K" exists.
      # The verification digit prevents users to input invalid VAT ID. If someone types "102688890", we know it is a wrong (invalid) VAT ID.
      response_rut = begin
        auth_hash['extra']['raw_info']['RolUnico']['numero'].to_s + auth_hash['extra']['raw_info']['RolUnico']['DV'].to_s
      rescue StandardError
        '0'
      end
      Rails.logger.info ">>>>>> Login with RUT - #{response_rut}"
      user = Spree::User.find_by_rut(Rut.formatear(response_rut))
      if user.present?
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: auth_hash['provider'])
        sign_in_and_redirect :spree_user, user
      else
        flash[:error] = I18n.t('devise.omniauth_callbacks.unauthorized_access', kind: auth_hash['provider'])
        redirect_back_or_default(root_url)
        return
      end

      if current_order
        user = spree_current_user || authentication.user
        current_order.associate_user!(user)
        session[:guest_token] = nil
      end
    end
  end
end

::Spree::OmniauthCallbacksController.prepend(Spree::OmniauthCallbacksControllerDecorator)
