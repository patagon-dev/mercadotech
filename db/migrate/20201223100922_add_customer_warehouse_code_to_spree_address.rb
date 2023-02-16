class AddCustomerWarehouseCodeToSpreeAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_addresses, :customer_warehouse_code, :string
  end
end
