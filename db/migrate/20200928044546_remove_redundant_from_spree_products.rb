class RemoveRedundantFromSpreeProducts < ActiveRecord::Migration[6.0]
  def change
    remove_column :spree_products, :redundant, :boolean, default: false
  end
end
