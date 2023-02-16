class AddEmailToStockLocation < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_stock_locations, :notification_email, :string
  end
end
