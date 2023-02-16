module Spree::VendorMailerDecorator
  def vendor_notification_email(order_id, vendor_id)
    @vendor = Spree::Vendor.find(vendor_id)
    return unless @vendor.notification_email.present?

    @order = Spree::Order.find_by(id: order_id)
    @current_store = @order.store
    @line_items = @order.line_items.for_vendor(@vendor)
    @subtotal = @order.vendor_subtotal(@vendor)
    @total = @order.vendor_total(@vendor)
    subject = "#{@current_store.name} #{Spree.t('order_mailer.vendor_notification_email.subject')} ##{@order.number}"
    mail(to: @vendor.notification_email, from: @current_store&.mail_from_address, subject: subject)
  end

  def send_import_error_notification(error_log_file, vendor_id)
    @vendor = Spree::Vendor.find_by(id: vendor_id)
    return unless @vendor.notification_email.present?

    attachments[error_log_file] = File.read(error_log_file)
    mail(to: @vendor.notification_email, subject: Spree.t(:import_error_subject, name: @vendor.name, date: Date.today.to_s))
  end

  Spree::VendorMailer.prepend Spree::VendorMailerDecorator
end
