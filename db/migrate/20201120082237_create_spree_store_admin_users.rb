class CreateSpreeStoreAdminUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_store_admin_users do |t|
	  t.references :store, index: true
	  t.references :user, index: true
	end
    add_index :spree_store_admin_users, [:store_id, :user_id], unique: true
  end
end
