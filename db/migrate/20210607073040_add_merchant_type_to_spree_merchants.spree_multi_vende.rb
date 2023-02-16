# This migration comes from spree_multi_vende (originally 20210607072305)
class AddMerchantTypeToSpreeMerchants < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_merchants, :merchant_type, :string
  end
end
