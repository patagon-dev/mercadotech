class AddFieldsToSpreeStockLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stock_locations, :google_place_id, :string
    add_column :spree_stock_locations, :latitude, :decimal, { precision: 10, scale: 6 }
    add_column :spree_stock_locations, :longitude, :decimal, { precision: 10, scale: 6 }
  end
end
