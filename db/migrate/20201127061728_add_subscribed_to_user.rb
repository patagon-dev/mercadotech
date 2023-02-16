class AddSubscribedToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :webpay_oneclick_mall_users, :subscribed, :boolean
  end
end
