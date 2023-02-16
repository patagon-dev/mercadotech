# This migration comes from spree_multi_domain (originally 20100227180338)
class CreateProductsStores < SpreeExtension::Migration[4.2]
  def self.up
    create_table :products_stores, :id => false do |t|
      t.references :product
      t.references :store
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :products_stores
  end
end