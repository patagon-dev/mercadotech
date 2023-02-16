class AddSolotodoIdToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :solotodo_id, :string
    add_index :spree_products, :solotodo_id
  end
end
