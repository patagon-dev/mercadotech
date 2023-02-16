class AddWebpayIdToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column(:spree_payments, :webpay_trx_id, :string) unless column_exists?(:spree_payments, :webpay_trx_id)
  end
end
