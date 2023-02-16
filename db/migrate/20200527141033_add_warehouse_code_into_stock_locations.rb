class AddWarehouseCodeIntoStockLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stock_locations, :enviame_warehouse_code, :string
  end
end
