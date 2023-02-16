module Spree
  class EnviameCarrier < ApplicationRecord
    has_many :enviame_carrier_services
    has_and_belongs_to_many :vendors
  end
end
