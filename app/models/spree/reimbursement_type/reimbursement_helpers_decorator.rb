module Spree::ReimbursementType::ReimbursementHelpersDecorator
  private

  def create_refund(reimbursement, payment, amount, simulate)
    refund = reimbursement.refunds.build(
      payment: payment,
      amount: amount,
      reason: Spree::RefundReason.return_processing_reason,
      refund_type: self.name
    )

    simulate ? refund.readonly! : refund.save!
    refund
  end

  ::Spree::ReimbursementType::ReimbursementHelpers.prepend self
end
