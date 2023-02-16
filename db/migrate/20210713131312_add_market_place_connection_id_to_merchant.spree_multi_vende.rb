# This migration comes from spree_multi_vende (originally 20210713130917)
class AddMarketPlaceConnectionIdToMerchant < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_merchants, :marketplace_connection_id, :string
  end
end
