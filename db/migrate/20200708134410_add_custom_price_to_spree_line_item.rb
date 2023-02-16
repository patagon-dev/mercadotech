class AddCustomPriceToSpreeLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_line_items, :custom_price, :decimal, precision: 10, scale: 2
  end
end
