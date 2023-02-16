module Spree
  module AuthenticationMethodDecorator
    def self.prepended(base)
      base.has_many :store_authentication_types
      base.has_many :stores, through: :store_authentication_types

      def base.active_methods
        where(environment: ::Rails.env, active: true)
      end

      base.scope :non_standard, -> { where.not(provider: 'standard') }
    end
  end
end

::Spree::AuthenticationMethod.prepend(Spree::AuthenticationMethodDecorator)
