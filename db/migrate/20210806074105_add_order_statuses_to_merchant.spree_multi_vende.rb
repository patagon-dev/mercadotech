# This migration comes from spree_multi_vende (originally 20210806051738)
class AddOrderStatusesToMerchant < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_merchants, :order_statuses, :json
    add_column :spree_merchants, :default_order_status, :string
  end
end
