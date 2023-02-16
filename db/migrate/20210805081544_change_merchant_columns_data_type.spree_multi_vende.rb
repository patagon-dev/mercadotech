# This migration comes from spree_multi_vende (originally 20210805081034)
class ChangeMerchantColumnsDataType < ActiveRecord::Migration[6.1]
  def self.up
    change_column :spree_merchants, :warehouse_ids, :json
    change_column :spree_merchants, :price_list_ids, :json
    change_column :spree_merchants, :error_logs, :json
  end

  def self.down
    change_column :spree_merchants, :warehouse_ids, :text
    change_column :spree_merchants, :price_list_ids, :text
    change_column :spree_merchants, :error_logs, :text
  end
end
