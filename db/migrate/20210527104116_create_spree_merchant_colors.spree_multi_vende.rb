# This migration comes from spree_multi_vende (originally 20210520101654)
class CreateSpreeMerchantColors < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_merchant_colors do |t|
      t.string :name
      t.string :vendor_id

      t.timestamps
    end
  end
end
