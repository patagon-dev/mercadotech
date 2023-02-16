class AddWebpayOneClickStoreCodeToSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :webpay_oneclick_store_code, :string
  end
end
