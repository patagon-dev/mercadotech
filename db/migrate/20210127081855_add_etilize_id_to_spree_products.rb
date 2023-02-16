class AddEtilizeIdToSpreeProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :etilize_id, :string
    add_index :spree_products, :etilize_id
  end
end
