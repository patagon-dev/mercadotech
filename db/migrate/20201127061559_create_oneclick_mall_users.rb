class CreateOneclickMallUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :webpay_oneclick_mall_users do |t|
      t.text    :tbk_user
      t.text    :authorization_code
      t.text    :card_type
      t.text    :card_number
      t.text    :card_expiration_date
      t.text    :card_origin
      t.integer :user_id

      t.timestamps
    end
  end
end
