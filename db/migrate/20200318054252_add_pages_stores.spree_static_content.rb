# This migration comes from spree_static_content (originally 20140926121757)
class AddPagesStores < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_pages_stores, id: false do |t|
      t.integer :store_id
      t.integer :page_id
      t.timestamps null: false
    end

    add_index :spree_pages_stores, :store_id
    add_index :spree_pages_stores, :page_id
  end
end
