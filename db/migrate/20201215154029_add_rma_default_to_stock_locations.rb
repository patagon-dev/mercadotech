class AddRMADefaultToStockLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stock_locations, :rma_default, :boolean, default: false
  end
end
