class AddPdfInvoiceOptionsToSpreeVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :superfactura_login, :string
    add_column :spree_vendors, :superfactura_password, :string
    add_column :spree_vendors, :superfactura_environment, :string
    add_column :spree_vendors, :invoice_options, :integer, default: 0
  end
end
