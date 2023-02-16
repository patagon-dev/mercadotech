# This migration comes from spree_multi_domain (originally 20121210224018)
class AddStorePaymentMethods < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_store_payment_methods do |t|
      t.integer :store_id
      t.integer :payment_method_id

      t.timestamps null: false
    end
  end
end
