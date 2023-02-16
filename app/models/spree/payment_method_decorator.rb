module Spree::PaymentMethodDecorator
  REFUND_PAYMENT_METHODS = [Spree::Gateway::WebpayOneclickMall, Spree::Gateway::WebpayWsMall, Spree::Gateway::WireTransfer].freeze

  def self.prepended(base)
    base.has_and_belongs_to_many :stores, through: :store_payment_methods
  end

  def available_for_store?(store)
    return true if store.blank? || !stores.any?

    if stores.any?
      stores.include?(store)
    elsif store_id
      store_id == store.id
    else
      false
    end
  end

  ::Spree::PaymentMethod.prepend self
end
