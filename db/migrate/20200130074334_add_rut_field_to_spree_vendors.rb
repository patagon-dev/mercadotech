class AddRutFieldToSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :rut, :string
  end
end
