class AddByPassStockToSpreeVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_variants, :by_pass_stock, :boolean, default: false
  end
end
