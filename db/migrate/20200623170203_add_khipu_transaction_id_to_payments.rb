class AddKhipuTransactionIdToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column(:spree_payments, :khipu_trx_id, :string) unless column_exists?(:spree_payments, :khipu_trx_id)
  end
end
