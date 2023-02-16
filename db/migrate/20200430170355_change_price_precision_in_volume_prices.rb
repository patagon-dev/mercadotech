class ChangePricePrecisionInVolumePrices < ActiveRecord::Migration[6.0]
  def self.up
    change_column :spree_volume_prices, :amount, :decimal
  end

   def self.down
    change_column :spree_volume_prices, :amount, :decimal, precision: 8, scale: 2
  end
end
