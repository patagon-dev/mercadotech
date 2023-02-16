require 'spree/testing_support/factories'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
