module Spree
  class StoreAuthenticationType < ActiveRecord::Base
    belongs_to :store
    belongs_to :authentication_method
  end
end
