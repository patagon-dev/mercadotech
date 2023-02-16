module Spree
  module ReturnAuthorizationEnums
    extend ActiveSupport::Concern
    included do
      enum range_time: %w[AM PM]
    end
  end
end
