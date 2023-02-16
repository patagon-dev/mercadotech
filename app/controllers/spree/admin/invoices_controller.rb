class Spree::Admin::InvoicesController < Spree::Admin::ResourceController
  before_action :load_order
  after_action :send_email_notification, only: :create

  def index
    @invoices = @order.invoices
    @vendors = current_spree_vendor ? [current_spree_vendor] : Spree::Vendor.active.joins(variants: :line_items).where('spree_line_items.order_id =?', @order.id).uniq
  end

  def create
    tipo_dte = params[:invoice_type]

    if @vendor.superfactura_api?
      # Use service, instead of performing bg job in order work email sending with invoice attachment.
      if tipo_dte.present?
        Superfactura::GenerateInvoice.new(@order.id, @vendor.id, tipo_dte).run
      end # SuperfacturaInvoiceWorker.perform_async(@payment.id)
    else
      if tipo_dte.present?
        @invoice = Spree::Invoice.new(invoice_params.merge!(order_id: @order.id, vendor_id: @vendor.id, tipo_dte: tipo_dte))
      end
      @invoice.save
    end
    redirect_back fallback_location: spree.admin_order_invoices_path(@order)
  end

  private

  def load_order
    @order = Spree::Order.find_by_number(params[:order_id])
    @vendor = Spree::Vendor.find_by_id(params[:vendor_id])
  end

  def send_email_notification
    invoice = @order.invoices.for_vendor(@vendor).take
    user = @order.user
    InvoiceMailer.send_invoice_notification(invoice.id, user.email).deliver_later if user.present? && invoice.present?
  end

  def invoice_params
    params.require(:invoice).permit(:number, :document, :order_id, :vendor_id, :via_superfactura)
  end
end
