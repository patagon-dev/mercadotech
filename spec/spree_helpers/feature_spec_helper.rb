require 'rails_helper'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'

module AuthenticationHelpers
  def sign_in_as!(user)
    visit spree.login_path
    fill_in 'spree_user_email', with: user.email
    fill_in 'spree_user_password', with: user.password
    click_button 'Login'
  end
end

RSpec.configure do |config|
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Rails.application.routes.url_helpers
  config.include AuthenticationHelpers, type: :feature
end
