class AddCheckForSkipImportScriptToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :skip_full_import, :boolean, default: false
    add_column :spree_products, :skip_quick_import, :boolean, default: false
  end
end
