class AddVendorIdToCustomerReturn < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_customer_returns, :vendor_id, :integer
    add_index :spree_customer_returns, :vendor_id
  end
end
