class AddStoreAuthenticationTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_store_authentication_types do |t|
      t.integer :store_id
      t.integer :authentication_method_id

      t.timestamps null: false
    end
  end
end