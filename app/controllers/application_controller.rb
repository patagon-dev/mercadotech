class ApplicationController < ActionController::Base
  def after_sign_in_path_for(_resource)
    return spree.admin_path if spree_current_user.has_spree_role?('admin')

    if params[:RelayState]
      uri_path = URI(params[:RelayState]).path
      uri_path == '/checkout/registration' ? spree.checkout_state_path(:address) : params[:RelayState]
    else
      spree.root_path
    end
  end

  unless Rails.env.producton?
    before_action do
      Rack::MiniProfiler.authorize_request if spree_current_user && spree_current_user.has_spree_role?('admin')
    end
  end
end
