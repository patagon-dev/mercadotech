require 'rails_helper'
require 'cancan/matchers'

require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'
require 'spree/api/testing_support/helpers'
require 'spree/api/testing_support/setup'

RSpec.configure do |config|
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Rails.application.routes.url_helpers
  config.include Spree::TestingSupport::UrlHelpers

  # For methods like stub_athentication! to use when testing api
  config.include Spree::Api::TestingSupport::Helpers, type: :controller
  config.extend Spree::Api::TestingSupport::Setup, type: :controller
end
