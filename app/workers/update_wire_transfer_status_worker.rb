class UpdateWireTransferStatusWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'compraagil_production_others', retry: false

  def perform(id)
    @refund_history = Spree::RefundHistory.find_by(id: id)
    @vendor = @refund_history.vendor

    Banks::VerifyTransaction.new(transaction_status_url, id)
  end

  private

  def transaction_status_url
    "#{@vendor.bank_transfer_url}check/#{@refund_history.transaction_id}"
  end
end