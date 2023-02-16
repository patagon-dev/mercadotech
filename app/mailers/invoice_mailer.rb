class InvoiceMailer < Spree::BaseMailer
  def send_invoice_notification(invoice_id, email)
    @invoice = Spree::Invoice.find_by(id: invoice_id)
    return false unless @invoice

    @current_store = @invoice.order.store
    filename = @invoice.document.filename.to_s
    attachments[filename] = { mime_type: 'application/pdf', content: @invoice.document.download }
    mail(to: email, from: store_from_address, subject: Spree.t(:order_purchase_invoice, number: @invoice.number))
  end

  private

  def store_from_address
    @current_store.mail_from_address.present? ? @current_store.mail_from_address : Spree::Store.default.mail_from_address
  end
end
