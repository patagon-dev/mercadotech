class ChangeAmountFieldInPayments < ActiveRecord::Migration[6.0]
  def self.up
    change_column :spree_payments, :amount, :decimal, precision: 18, scale: 2, default: "0.0", null: false
    change_column :spree_payment_capture_events, :amount, :decimal, precision: 18, scale: 2, default: "0.0"
  end

  def self.down
    change_column :spree_payments, :amount, :decimal, precision: 10, scale: 2, default: "0.0", null: false
    change_column :spree_payment_capture_events, :amount, :decimal, precision: 10, scale: 2, default: "0.0"
  end
end
