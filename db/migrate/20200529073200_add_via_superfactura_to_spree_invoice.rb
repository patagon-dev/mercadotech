class AddViaSuperfacturaToSpreeInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_invoices, :via_superfactura, :boolean, default: false
    remove_reference :spree_invoices, :payment, index: true
    add_reference :spree_invoices, :order, index: true
    add_reference :spree_invoices, :vendor, index: true
  end
end
