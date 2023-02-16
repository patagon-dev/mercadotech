class Spree::ReimbursementType::WebpayNormal < Spree::ReimbursementType
  extend Spree::ReimbursementType::ReimbursementHelpers

  class << self
    def reimburse(reimbursement, return_items, simulate)
      original_unpaid_amount = return_items.map { |ri| ri.total.to_d.round(2) }.sum
      vendor_id = reimbursement.customer_return&.vendor_id
      payments = reimbursement.order.payments.completed.from_webpay_ws_mall.where('amount > ? and vendor_id = ?', 0, vendor_id)

      return [] unless payments.any?

      reimbursement_list, unpaid_amount = create_refunds(reimbursement, payments, original_unpaid_amount, true)

      if reimbursement_list.present? && !simulate
        amount = reimbursement_list.pluck(:amount).sum
        payment = payments.take
        provider = payment.payment_method.provider.new(reimbursement.order.number, amount.to_f, payment.number)

        if provider.nullify_payment(vendor_id, reimbursement.number)
          reimbursement_list, unpaid_amount = create_refunds(reimbursement, payments, original_unpaid_amount, simulate)
          reimbursement.refunds.reload
        else
          reimbursement.refunds.reload
          return []
        end
      end

      reimbursement_list
    end
  end
end
