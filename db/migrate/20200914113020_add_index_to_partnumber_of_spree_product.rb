class AddIndexToPartnumberOfSpreeProduct < ActiveRecord::Migration[6.0]
  def change
    add_index :spree_products, :partnumber
  end
end
