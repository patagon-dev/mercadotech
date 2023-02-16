class AddColumnToSpreeStockLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stock_locations, :enable_stock_api, :boolean, default: false
    add_column :spree_stock_locations, :stock_api_url, :string
  end
end
