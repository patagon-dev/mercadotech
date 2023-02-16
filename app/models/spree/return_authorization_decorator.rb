module Spree
  module ReturnAuthorizationDecorator
    def self.prepended(base)
      base.include Spree::ReturnAuthorizationEnums
      base.has_one :shipment_label
      base.belongs_to :vendor, optional: true
      base.validates :stock_location, presence: true, unless: :user_initiated?
      base.validates :return_items, presence: true, if: :user_initiated?
      base.after_commit :create_return_delivery, on: :create
    end

    def return_items_weight
      return_items.map { |item| item&.inventory_unit&.variant }.compact.sum(&:weight).to_f
    end

    def pending_pickup?
      request_pickup && !pickup_generated
    end

    def fully_reimbursed?
      !return_items.undecided.exists? && return_items.accepted.includes(:reimbursement).all? { |return_item| return_item.reimbursement.try(:reimbursed?) }
    end

    private

    def create_return_delivery
      ReturnDeliveryWorker.perform_async(number) if user_initiated?
    end
  end
end

::Spree::ReturnAuthorization.prepend Spree::ReturnAuthorizationDecorator
