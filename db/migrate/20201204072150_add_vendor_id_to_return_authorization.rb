class AddVendorIdToReturnAuthorization < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_return_authorizations, :vendor_id, :integer
    add_index :spree_return_authorizations, :vendor_id
  end
end
