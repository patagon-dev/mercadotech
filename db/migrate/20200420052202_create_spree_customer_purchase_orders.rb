class CreateSpreeCustomerPurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_customer_purchase_orders do |t|
      t.string :purchase_order_number
      t.references :vendor
      t.references :order

      t.timestamps
    end
  end
end