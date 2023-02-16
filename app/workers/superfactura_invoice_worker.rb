class SuperfacturaInvoiceWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'compraagil_production_others', retry: false

  def perform(payment_id)
    Superfactura::GenerateInvoice.new(payment_id).run
  end
end
