class AddDatasheetToSpreeProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :datasheet, :json
  end
end
