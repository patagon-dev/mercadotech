class AddStatusFieldToSpreeCompraPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_micro_compra_purchase_orders, :status, :integer
  end
end
