class AddEnviameVendorIdFieldIntoVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :enviame_vendor_id, :integer
  end
end
