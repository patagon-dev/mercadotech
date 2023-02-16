class AddNewFieldsToWebpayOneclickMallUser < ActiveRecord::Migration[6.0]
  def change
    add_column :webpay_oneclick_mall_users, :default, :boolean, default: false
    add_column :webpay_oneclick_mall_users, :shares_number, :string, default: '1'
  end
end
