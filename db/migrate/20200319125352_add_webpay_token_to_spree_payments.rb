class AddWebpayTokenToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column(:spree_payments, :webpay_token, :string) unless column_exists?(:spree_payments, :webpay_token)
  end
end
