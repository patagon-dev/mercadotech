class AddWebpayParamsToSpreePayments < ActiveRecord::Migration[6.0]
  def up
    add_column(:spree_payments, :webpay_params, :json) unless column_exists?(:spree_payments, :webpay_params)
  end

  def down
    remove_column :spree_payments, :webpay_params
  end
end
