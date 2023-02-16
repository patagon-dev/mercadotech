module Spree
  module UserSessionsControllerDecorator
    private

    # Override as there is no login page
    def after_sign_out_redirect(_resource_or_scope)
      '/'
    end
  end
end

::Spree::UserSessionsController.prepend Spree::UserSessionsControllerDecorator
