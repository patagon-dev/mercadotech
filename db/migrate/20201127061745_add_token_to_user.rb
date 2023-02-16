class AddTokenToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :webpay_oneclick_mall_users, :token, :text
  end
end
