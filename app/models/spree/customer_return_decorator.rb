module Spree
  module CustomerReturnDecorator
    def self.prepended(base)
      base.belongs_to :vendor, optional: true
      base.after_create :customer_return_notification
    end

    def customer_return_notification
      Spree::CustomerReturnMailer.email_notification(order.id).deliver_later
    end
  end
end

::Spree::CustomerReturn.prepend Spree::CustomerReturnDecorator
