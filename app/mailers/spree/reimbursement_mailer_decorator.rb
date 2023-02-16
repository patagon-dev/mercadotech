module Spree::ReimbursementMailerDecorator
  def reimbursement_email(reimbursement, resend = false)
    @reimbursement = reimbursement.respond_to?(:id) ? reimbursement : Spree::Reimbursement.find(reimbursement)
    @current_store = @reimbursement.order.store
    super
  end

  Spree::ReimbursementMailer.prepend Spree::ReimbursementMailerDecorator
end
