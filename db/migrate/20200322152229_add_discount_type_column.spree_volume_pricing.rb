# This migration comes from spree_volume_pricing (originally 20121115043422)
class AddDiscountTypeColumn < SpreeExtension::Migration[4.2]
  def change
    add_column :spree_volume_prices, :discount_type, :string
  end
end
