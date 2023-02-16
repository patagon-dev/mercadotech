class RemoveTaxFieldFromSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    remove_column :spree_vendors, :tax_id, :string
  end
end
