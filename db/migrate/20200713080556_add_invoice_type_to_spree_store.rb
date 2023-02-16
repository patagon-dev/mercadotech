class AddInvoiceTypeToSpreeStore < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stores, :invoice_types, :string, default: [].to_yaml
    add_column :spree_addresses, :document_type, :string
  end
end
