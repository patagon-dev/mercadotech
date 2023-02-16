Devise.secret_key = '3699d891833f75aa6411c5f04a56e45a44235595641d61cdba61b53b2d5f0b564173997e28d254eb02ca84156dfeba64430e'

Devise.setup do |config|
  # config.omniauth :openid_connect, {
  #   name: :openid_connect,
  #   scope: %i[openid email],
  #   response_type: :code,
  #   issuer: 'https://accounts.claveunica.gob.cl/openid',
  #   client_auth_method: 'query',
  #   discovery: true,
  #   uid_field: 'preferred_username',
  #   client_options: {
  #     # port: 443,
  #     # scheme: "https",
  #     # host: "accounts.claveunica.gob.cl",
  #     identifier: Rails.application.credentials[:clave_unica][:client_id],
  #     secret: Rails.application.credentials[:clave_unica][:client_secret],
  #     redirect_uri: 'https://www.mercadogobierno.cl/users/auth/openid_connect/callback'
  #   }
  # }

  # ==> Configuration for :saml_authenticatable

  # Create user if the user does not exist. (Default is false)
  config.saml_create_user = true

  # Update the attributes of the user after a successful login. (Default is false)
  config.saml_update_user = true

  # Set the default user key. The user will be looked up by this key. Make
  # sure that the Authentication Response includes the attribute.
  config.saml_default_user_key = :email

  # Optional. This stores the session index defined by the IDP during login.  If provided it will be used as a salt
  # for the user's session to facilitate an IDP initiated logout request.
  # config.saml_session_index_key = :session_index

  # You can set this value to use Subject or SAML assertation as info to which email will be compared.
  # If you don't set it then email will be extracted from SAML assertation attributes.
  config.saml_use_subject = true

  # You can support multiple IdPs by setting this value to the name of a class that implements a ::settings method
  # which takes an IdP entity id as an argument and returns a hash of idp settings for the corresponding IdP.
  # config.idp_settings_adapter = "MyIdPSettingsAdapter"
  config.saml_sign_out_success_url = '/'
  # You provide you own method to find the idp_entity_id in a SAML message in the case of multiple IdPs
  # by setting this to the name of a custom reader class, or use the default.
  # config.idp_entity_id_reader = "DeviseSamlAuthenticatable::DefaultIdpEntityIdReader"

  # You can set a handler object that takes the response for a failed SAML request and the strategy,
  # and implements a #handle method. This method can then redirect the user, return error messages, etc.
  # config.saml_failed_callback = nil

  # You can customize the named routes generated in case of named route collisions with
  # other Devise modules or libraries. Set the saml_route_helper_prefix to a string that will
  # be appended to the named route.
  # If saml_route_helper_prefix = 'saml' then the new_user_session route becomes new_saml_user_session
  # config.saml_route_helper_prefix = 'saml'

  # You can add allowance for clock drift between the sp and idp.
  # This is a time in seconds.
  # config.allowed_clock_drift_in_seconds = 0

  # Configure with your SAML settings (see ruby-saml's README for more information: https://github.com/onelogin/ruby-saml).
  # config.saml_configure do |settings|
  #   # assertion_consumer_service_url is required starting with ruby-saml 1.4.3: https://github.com/onelogin/ruby-saml#updating-from-142-to-143
  #   settings.assertion_consumer_service_url     = "http://localhost:3000/saml/auth"
  #   settings.assertion_consumer_service_binding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
  #   settings.name_identifier_format             = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  #   settings.issuer                             = "http://localhost:3000/saml/metadata"
  #   settings.authn_context                      = ""
  #   settings.idp_sso_target_url                 = "https://login.mercadoempresas.cl/auth/realms/mercadoempresas/protocol/saml"
  #   settings.idp_cert                           = "MIICrzCCAZcCBgF0q3zvEzANBgkqhkiG9w0BAQsFADAbMRkwFwYDVQQDDBBNZXJjYWRvIEVtcHJlc2FzMB4XDTIwMDkyMDEyMjcwNVoXDTMwMDkyMDEyMjg0NVowGzEZMBcGA1UEAwwQTWVyY2FkbyBFbXByZXNhczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPMId+Ge8Ix8duNEG0LrxzT35y1g7vaFNE5Bm9tTOE2dKalpj/ghJgsKXtdKNNSBFIk/Tv+JI9BrUhtRr9ISUx7k5inyG1kDmBWxSSRryJyWxY94gofmXNxLRuuiyxfQbkfF0z47BI4SamZHv4I4y6puuY6AtA+47TtlWpkTN4IFDCqbG+Kkkge7BY5mMgxpLTJiQ2K15oKNfBvo1pJ1FxM4CAv9d86N6uU6AcSl9zgeXcpFJD4Nh20Z1m2fmOjvKs7xL4u3JwiuKVLE+5GXzUpubvaLkObZnQA0E7FwEEmj2J+huAKqoVJFF4xZfvrXeeCtdMfnT0tja3tv3zFUabECAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAW9USWELqUV9n5q2Huep9HMHoU4XUCjEPQPa8/N3PXIEb861zj7t6SxC+lqCMz781TOIGrREXv3D4S2QTEOKymTwU/EtnuVByRwRhAzbr63ccuBhubnmU39YmMaQ9gb3r//TEE9o6BM2AV5K6htzl60cn9sx4pHHjU/eQK5lsgb5rVaZeXiyUa09YGpx8BWICSCHDKXDxE1IceKnWZEfU2ncxjUViyky8bnltiTLVcsbYbWbqYjdiQh4xgPmKOxAQ16O+tOmbxK70y8Ey3rqZwU56RO1ymcW2kTz320TSEdIAyFLbDZp8fBSAEbYAsQbzzH8ISg4IMJKu5rUPJt61YQ=="
  # end
end
