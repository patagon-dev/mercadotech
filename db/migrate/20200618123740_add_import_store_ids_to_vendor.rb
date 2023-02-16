class AddImportStoreIdsToVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :import_store_ids, :string, default: Spree::Store.ids.map(&:to_s).to_yaml
    add_column :spree_vendors, :import_options, :integer, default: 0
    add_column :spree_vendors, :scrapinghub_imported_at, :datetime
    add_column :spree_vendors, :scrapinghub_api_key, :string
    add_column :spree_vendors, :scrapinghub_project_id, :string
    add_column :spree_vendors, :full_spider_id, :string
    add_column :spree_vendors, :quick_spider_id, :string
    add_column :spree_variants, :additional_data, :text
  end
end
