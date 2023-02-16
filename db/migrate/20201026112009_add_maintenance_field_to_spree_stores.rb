class AddMaintenanceFieldToSpreeStores < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stores, :maintenance_mode, :boolean, default: false
    add_column :spree_stores, :maintenance_message, :text
  end
end
