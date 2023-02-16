# Not in user, using SAML SSO for login/signup
# if ActiveRecord::Base.connection.data_source_exists? 'spree_authentication_methods'
#   Spree::AuthenticationMethod.where(environment: Rails.env, provider: 'openid_connect').first_or_create do |auth_method|
#     auth_method.api_key = Rails.application.credentials[:clave_unica][:client_id]
#     auth_method.api_secret = Rails.application.credentials[:clave_unica][:client_secret]
#     auth_method.active = true
#   end

#   Spree::AuthenticationMethod.find_or_create_by(environment: Rails.env, provider: 'standard', api_key: 'not in use', api_secret: 'not in use', active: true)
# end
