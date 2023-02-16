class AddWebpayStoreCodeToSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :webpay_ws_mall_store_code, :string
  end
end
