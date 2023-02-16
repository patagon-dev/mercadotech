module Spree
  module Checkout
    class CustomStoreCredit
      prepend Spree::ServiceModule::Base

      def call(order:, amount: nil, vendor_id: nil)
        @order = order
        return failed unless @order

        vendor_ids = vendor_id.present? ? [vendor_id] : @order.products.pluck(:vendor_id)
        vendors = Spree::Vendor.where(id: vendor_ids)

        ApplicationRecord.transaction do
          @order.payments.store_credits.where(state: :checkout).map(&:invalidate!)

          @processed_credit_ids = []
          @shared_credits = {}
          amount = @order.outstanding_balance

          vendors.each do |vendor|
            remaining_total = amount ? [amount, vendor.total_amount(@order)].min : vendor.total_amount(@order)
            apply_store_credits(remaining_total, vendor.id) if @order.user&.store_credits&.any?
          end
        end

        @order.reload.payments.store_credits.valid.any? ? success(@order) : failure(@order)
      end

      private

      def apply_store_credits(remaining_total, vendor_id)
        payment_method = Spree::PaymentMethod::StoreCredit.available.first
        raise 'Store credit payment method could not be found' unless payment_method

        @order.user.store_credits.where.not(id: @processed_credit_ids).order_by_priority.each do |credit|
          break if remaining_total.zero?
          if credit.amount_remaining.zero? || (@shared_credits[credit.id].present? && @shared_credits[credit.id].zero?)
            next
          end

          amount_remaining = @shared_credits[credit.id].present? ? @shared_credits[credit.id] : credit.amount_remaining

          full_credit_used = amount_remaining.to_d < remaining_total.to_d
          @processed_credit_ids.push(credit.id) if full_credit_used

          amount_to_take = store_credit_amount(credit, remaining_total)
          @shared_credits[credit.id] = amount_remaining.to_d - remaining_total.to_d unless full_credit_used
          create_store_credit_payment(payment_method, credit, amount_to_take, vendor_id)
          remaining_total -= amount_to_take
        end
      end

      def create_store_credit_payment(payment_method, credit, amount, vendor_id)
        @order.payments.create!(
          source: credit,
          payment_method: payment_method,
          amount: amount,
          state: 'checkout',
          response_code: credit.generate_authorization_code,
          vendor_id: vendor_id
        )
      end

      def store_credit_amount(credit, total)
        remaining_amount = @shared_credits[credit.id].present? ? @shared_credits[credit.id] : credit.amount_remaining
        [remaining_amount, total].min
      end
    end
  end
end
