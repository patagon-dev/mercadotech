class ChangeAmountFieldInSpreeStoreCredits < ActiveRecord::Migration[6.0]
  def self.up
    change_column :spree_store_credits, :amount, :decimal
    change_column :spree_store_credits, :amount_used, :decimal
    change_column :spree_store_credits, :amount_authorized, :decimal
    change_column :spree_store_credit_events, :amount, :decimal
    change_column :spree_store_credit_events, :user_total_amount, :decimal
  end

   def self.down
    change_column :spree_store_credits, :amount, :decimal, precision: 8, scale: 2
    change_column :spree_store_credits, :amount_used, :decimal, precision: 8, scale: 2
    change_column :spree_store_credits, :amount_authorized, :decimal, precision: 8, scale: 2
    change_column :spree_store_credit_events, :amount, :decimal, precision: 8, scale: 2
    change_column :spree_store_credit_events, :user_total_amount, :decimal, precision: 8, scale: 2
  end
end