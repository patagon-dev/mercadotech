class AddReferenceOrderNumbersToSpreeOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_orders, :reference_order_numbers, :string
  end
end
