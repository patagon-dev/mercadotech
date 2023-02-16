# This migration comes from spree_multi_domain (originally 20130325231147)
class AddStoreShippingMethods < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_store_shipping_methods do |t|
      t.integer :store_id
      t.integer :shipping_method_id

      t.timestamps null: false
    end

    add_index :spree_store_shipping_methods, :store_id
    add_index :spree_store_shipping_methods, :shipping_method_id
  end
end

