class AddSpiderNameToSpreeVendor < ActiveRecord::Migration[6.0]
  def change
    rename_column :spree_vendors, :quick_spider_id, :quick_spider
    rename_column :spree_vendors, :full_spider_id, :full_spider
    remove_column :spree_variants, :additional_data, :text
  end
end
