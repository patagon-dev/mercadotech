module Spree::StockLocationDecorator
  def self.prepended(base)
    base.after_save :ensure_one_rma_default, if: proc { |st| st.has_attribute?('rma_default') }
    base.scope :rma_default, -> { where(rma_default: true) }
    base.scope :default, -> { where(default: true) }
  end

  def full_address
    [address1, address2, city, state_text, country&.name, zipcode].compact.reject { |e| e.to_s.empty? }.join(', ')
  end

  def to_xls_worksheet
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(name: 'Stock Location Report')
    sheet1.row(0).replace ['Sku', 'Product Name', 'Quantity', 'Product Price']

    stock_items.where('count_on_hand > ?', 0).includes(variant: %i[default_price product]).each_with_index do |stock_item, index|
      variant = stock_item.variant
      sheet1.row(index + 1).replace([variant.sku, variant.name, stock_item.count_on_hand, variant.display_price.to_s])
    end
    book
  end

  private

  # One rma_default per vendor
  def ensure_one_rma_default
    if rma_default
      Spree::StockLocation.where(rma_default: true, vendor_id: vendor_id).where.not(id: id).update_all(rma_default: false)
    end
  end

  # One default per vendor
  def ensure_one_default
    if default
      Spree::StockLocation.where(default: true, vendor_id: vendor_id).where.not(id: id).update_all(default: false)
    end
  end

  Spree::StockLocation.prepend self
end
