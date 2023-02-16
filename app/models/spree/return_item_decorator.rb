module Spree
  module ReturnItemDecorator
    def returned?
      inventory_unit.shipped? && !reimbursement
    end
  end
end

::Spree::ReturnItem.prepend Spree::ReturnItemDecorator
