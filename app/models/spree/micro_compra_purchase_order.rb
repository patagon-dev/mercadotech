module Spree
  class MicroCompraPurchaseOrder < Spree::Base
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :vendor, class_name: 'Spree::Vendor'

    enum status: %w[success failed]
  end
end
