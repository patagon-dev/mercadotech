class Spree::ReimbursementType::BankTransfer < Spree::ReimbursementType
  extend Spree::ReimbursementType::ReimbursementHelpers

  class << self
    def reimburse(reimbursement, return_items, simulate)
      original_unpaid_amount = return_items.map { |ri| ri.total.to_d.round(2) }.sum
      payments = reimbursement.order.payments.completed
      check_default_bank_account_exist = reimbursement.order&.user ? reimbursement.order&.user&.bank_accounts&.default&.any? : Spree::BankAccount.guest_user_account(reimbursement.order&.email).default.any?

      return [] unless check_default_bank_account_exist

      reimbursement_list, unpaid_amount = create_refunds(reimbursement, payments, original_unpaid_amount, true)
      if reimbursement_list.present? && !simulate && check_default_bank_account_exist
        vendor = reimbursement.customer_return&.stock_location&.vendor
        amount = reimbursement_list.pluck(:amount).sum
        if vendor&.bank_transfer_url
          api_response = Banks::RefundMoney.new(reimbursement.number, amount,
                                                vendor.id).execute
        end

        if api_response[:success]
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
