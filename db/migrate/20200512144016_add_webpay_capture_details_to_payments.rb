class AddWebpayCaptureDetailsToPayments < ActiveRecord::Migration[6.0]
  def up
    add_column(:spree_payments, :webpay_capture_params, :json) unless column_exists?(:spree_payments, :webpay_capture_params)
  end

  def down
    remove_column :spree_payments, :webpay_capture_params
  end
end
