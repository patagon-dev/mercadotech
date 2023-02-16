class AddManufacturerFieldToSpreeProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :partnumber, :string
    add_column :spree_products, :manufacturer, :string
  end
end
