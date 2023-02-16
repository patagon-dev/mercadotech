# This migration comes from spree_multi_vende (originally 20210520084127)
class CreateSpreeMerchantShippingCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_merchant_shipping_categories do |t|
      t.string :name
      t.string :vendor_id

      t.timestamps
    end
  end
end
