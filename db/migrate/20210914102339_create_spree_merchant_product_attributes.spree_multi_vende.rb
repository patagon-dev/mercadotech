# This migration comes from spree_multi_vende (originally 20210818041809)
class CreateSpreeMerchantProductAttributes < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_merchant_product_attributes do |t|
      t.string :name
      t.belongs_to :vendor, index: true

      t.timestamps
    end
  end
end
