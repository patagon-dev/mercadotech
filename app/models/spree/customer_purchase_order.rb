module Spree
  class CustomerPurchaseOrder < Spree::Base
    MAX_LENGTH = 18
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :vendor, class_name: 'Spree::Vendor'

    has_one_attached :purchase_order

    scope :for_vendor, ->(vendor) { where(vendor_id: vendor.id) }
  end
end
