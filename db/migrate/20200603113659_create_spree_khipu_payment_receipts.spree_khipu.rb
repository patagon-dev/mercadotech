# This migration comes from spree_khipu (originally 20141219175454)
class CreateSpreeKhipuPaymentReceipts < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_khipu_payment_receipts do |t|
      t.string :api_version
      t.string :receiver_id
      t.string :subject
      t.integer :amount
      t.string :custom
      t.string :currency
      t.string :transaction_id
      t.string :notification_id
      t.string :payer_email

      t.timestamps
    end
  end
end
