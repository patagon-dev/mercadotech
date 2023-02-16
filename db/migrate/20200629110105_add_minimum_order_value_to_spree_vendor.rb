class AddMinimumOrderValueToSpreeVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :set_minimum_order, :boolean, default: false
    add_column :spree_vendors, :minimum_order_value, :decimal, precision: 12, scale: 2
  end
end
