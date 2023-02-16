class Spree::Gateway::MicroCompra < Spree::Gateway
  def provider_class
    Spree::Gateway::MicroCompra
  end

  def payment_source_class; end

  def method_type
    'micro_compra'
  end

  def source_required?
    false
  end

  def auto_capture?
    true
  end

  def purchase(amount, transaction_details, options = {})
    response = Payment::MicroCompra.purchase!(amount, transaction_details, options)
    ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
  end
end
