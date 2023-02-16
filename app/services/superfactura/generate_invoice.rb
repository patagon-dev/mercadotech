require_relative './base'

class Superfactura::GenerateInvoice
  attr_reader :vendor, :order, :tipo_dte, :pdf_file_path

  def initialize(order_id, vendor_id, invoice_type)
    @order = Spree::Order.find_by(id: order_id)
    @vendor = Spree::Vendor.find_by(id: vendor_id)
    @pdf_file_path = "tmp/dte-#{@order.number}"
    @tipo_dte = invoice_type.to_i
  end

  def run
    api = Superfactura::Base.new(@vendor.superfactura_login, vendor.superfactura_password)
    build_dte_data

    result = api.SendDTE(
      @dte_data, vendor.superfactura_environment, { 'savePDF' => pdf_file_path }
    )

    if result['ok']
      puts 'Folio:' + result['folio']
      create_invoice_with_document(result['folio']) # Create Invoice
    else
      puts 'Error'
    end
  end

  private

  def build_dte_data
    @items = []
    bill_address = order.bill_address.present? ? order.bill_address : order.user.bill_address
    ship_address = order.ship_address.present? ? order.ship_address : order.user.ship_address
    company_rut = bill_address.company_rut.blank? ? '00000000-0' : bill_address.company_rut
    @payment_method = order.payments.take&.payment_method

    build_order_data
    build_shipment_data
    additional_data = build_additional_data
    receptor_data = build_receptor_data(bill_address, company_rut)

    @dte_data = {
      'SuperFactura' => {
        'Observaciones' => "Order: #{order.number}, Payment Type: #{@payment_method&.name}, Shipping Address: #{ship_address.full_street_address}, Contact Name: #{ship_address.full_name}"
      },
      'Encabezado' => {
        'IdDoc' => {
          'TipoDTE' => tipo_dte,
          'IndServicio' => 3 # For selling type i.e goods and services
        }.merge!(additional_data),
        'Emisor' => {
          'RUTEmisor' => vendor.rut.gsub(/\./mi, '') # '76124329-2'
        }
      }.merge!(receptor_data),
      'Detalles' => @items
    }

    @dte_data.merge!(build_reference_data)
    @dte_data.merge!(build_discount_data)
    @dte_data.merge!(build_credit_note) if tipo_dte == 61
  end

  # Additional data
  def build_additional_data
    return { 'IndTraslado' => 2 } if tipo_dte == 52

    if tipo_dte == 33
      { 'FmaPago' => order.payment_state == 'paid' ? 1 : 2 }
    else
      {}
    end
  end

  # Receptor data
  def build_receptor_data(bill_address, company_rut)
    conditional_data = tipo_dte == 39 ? { 'RznSocRecep' => bill_address.full_name || '--' } : { 'RznSocRecep' => bill_address.company || '--', 'GiroRecep' => bill_address.company_business || '--' }
    conditional_data.merge!({
                              'DirRecep' => bill_address.full_street_address,
                              'CmnaRecep' => bill_address.county&.name || '--'
                            })

    {
      'Receptor' => {
        'RUTRecep' => company_rut.gsub(/\./mi, '') # '77.803.520-0'
      }.merge!(conditional_data)
    }
  end

  # Order Items details
  def build_order_data
    line_items = order.line_items.select { |li| li.variant.vendor_id == vendor.id }
    line_items.each do |item|
      item_data = {
        'NmbItem' => item.name&.truncate(80),
        'DscItem' => item.product.partnumber,
        'QtyItem' => item.quantity,
        'PrcItem' => tipo_dte == 39 ? item.price.round : (item.price / 1.19).round
      }
      @items.push(item_data)
    end
  end

  # Shipment
  def build_shipment_data
    shipments = order.shipments.for_vendor(vendor)
    shipment_amount = shipments.map(&:final_price).sum.round

    if shipment_amount > 0
      shipment_data = {
        'NmbItem' => shipments.take&.selected_shipping_rate&.name || 'Shipping',
        'DscItem' => '',
        'QtyItem' => 1,
        'PrcItem' => tipo_dte == 39 ? shipment_amount.round : (shipment_amount / 1.19).round
      }
      @items.push(shipment_data)
    end
  end

  # Reference data
  def build_reference_data
    # Backend order
    bill_address = order.bill_address.present? ? order.bill_address : order.user.bill_address
    purchase_order_number = bill_address&.purchase_order_number
    created_at = order.completed_at.strftime('%Y-%m-%d') if purchase_order_number.present?

    # Frontend order
    return {} unless @payment_method&.store_credit? && purchase_order_number

    unless purchase_order_number
      customer_purchase_order = order.customer_purchase_orders.for_vendor(vendor).take

      purchase_order_number = customer_purchase_order&.purchase_order_number
      created_at = customer_purchase_order&.created_at&.strftime('%Y-%m-%d')
    end

    {
      'Referencia' => {
        'NroLinRef' => 1,
        'TpoDocRef' => 801,
        'FolioRef' => purchase_order_number.to_s,
        'FchRef' => created_at.to_s
      }
    }
  end

  # Credit Note
  def build_credit_note
    invoice = order.invoices.for_vendor(vendor).first
    return {} unless invoice.present?

    type = invoice.document.filename.to_s.split('_')[0].to_i
    date = invoice.created_at&.strftime('%Y-%m-%d')

    {
      'Referencia' => {
        'NroLinRef' => 1,
        'TpoDocRef' => type,
        'FolioRef' => invoice.number.to_i,
        'FchRef' => date,
        'CodRef' => 1
      }
    }
  end

  # Discount data
  def build_discount_data
    discount = order.adjustments.pluck(:amount).sum.abs.to_f
    return {} if discount <= 0

    vendor_total = vendor.total_amount(order)
    v_discount = ((vendor_total / (order.total + discount).to_f).round(2) * discount).to_f.round(2)
    v_discount = tipo_dte == 39 ? v_discount.round(2) * -1 : (v_discount / 1.19).round(2) * -1

    {
      'DscRcgGlobal' => [{
        'TpoMov' => 'D', # 'D' = Discount, 'R' = Surcharge
        'GlosaDR' => 'Descuento',
        'TpoValor' => '$', # '$' = amount, '%' = percentage
        'ValorDR' => v_discount * -1 # vendor discount
      }]
    }
  end

  def create_invoice_with_document(pdf_number)
    invoice_pdf = "#{pdf_file_path}.pdf"

    ActiveRecord::Base.transaction do
      invoice = Spree::Invoice.new(number: pdf_number, order_id: order.id, vendor_id: vendor.id, via_superfactura: true)
      invoice.save
      response = invoice.document.attach({ io: File.open(invoice_pdf), filename: "#{tipo_dte}_#{invoice.number}.pdf" }) # Attaching pdf document

      File.delete(invoice_pdf) if response # Deleting file from server
    rescue Exception => e
      puts "ERROR: #{e}"
    end
  end
end
