class AddSkipImportFieldToStockLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stock_locations, :skip_from_import, :boolean, default: false
  end
end
