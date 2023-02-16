# This migration comes from spree_multi_vende (originally 20210805074544)
class RenameColumns < ActiveRecord::Migration[6.1]
  def self.up
    rename_column :spree_merchants, :warehouse_id, :warehouse_ids
    rename_column :spree_merchants, :price_list_id, :price_list_ids
  end

  def self.down
    rename_column :spree_merchants, :warehouse_ids, :warehouse_id
    rename_column :spree_merchants, :price_list_ids, :price_list_id
  end
end
