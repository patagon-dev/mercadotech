class AddAmountRefundedToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_payments, :amount_refunded, :boolean, default: false
  end
end
