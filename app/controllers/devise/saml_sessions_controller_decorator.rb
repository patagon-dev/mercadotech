require 'ruby-saml'
require './lib/devise_saml_authenticatable/saml_config'

module Devise
  module SamlSessionsControllerDecorator
    def self.prepended(base)
      base.include Spree::Core::ControllerHelpers::Store
      base.before_action :update_comment_cookie, only: [:destroy, :idp_sign_out]
    end

    def new
      idp_entity_id = get_idp_entity_id(params)
      referrer = request.referrer || spree.root_path
      request = OneLogin::RubySaml::Authrequest.new
      auth_params = { RelayState: referrer } if referrer
      action = request.create(saml_config(idp_entity_id), auth_params || {})
      redirect_to action
    end

    protected

    # For non transient name ID, save info to identify user for logout purpose
    # before that user's session got destroyed. These info are used in the
    # `after_sign_out_path_for` method below.
    def store_info_for_sp_initiated_logout
      return if Devise.saml_config.name_identifier_format == 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'

      @name_identifier_value_for_sp_initiated_logout = Devise.saml_name_identifier_retriever.call(spree_current_user)
      if Devise.saml_session_index_key
        @sessionindex_for_sp_initiated_logout = spree_current_user.public_send(Devise.saml_session_index_key)
      end
    end

    private

    def update_comment_cookie
      cookies['commentoCommenterToken'] = 'anonymous'
    end
  end
end

::Devise::SamlSessionsController.prepend Devise::SamlSessionsControllerDecorator
