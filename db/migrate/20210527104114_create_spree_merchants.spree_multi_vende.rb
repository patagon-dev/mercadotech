# This migration comes from spree_multi_vende (originally 20210519061211)
class CreateSpreeMerchants < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_merchants do |t|
      t.string :merchant_id
      t.string :name
      t.string :fullname
      t.string :default_price_list_id
      t.string :default_warehouse_id
      t.string :refresh_token
      t.text :price_list_id
      t.text :warehouse_id
      t.text :token
      t.text :error_logs
      t.datetime :token_expire_at
      t.belongs_to :user
      t.belongs_to :vendor
      t.belongs_to :multivende

      t.timestamps
    end
  end
end
