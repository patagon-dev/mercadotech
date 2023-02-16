class AddRedundantToSpreeProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :redundant, :boolean, default: false
  end
end
