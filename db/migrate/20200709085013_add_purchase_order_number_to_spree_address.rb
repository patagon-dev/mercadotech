class AddPurchaseOrderNumberToSpreeAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_addresses, :purchase_order_number, :string
  end
end
