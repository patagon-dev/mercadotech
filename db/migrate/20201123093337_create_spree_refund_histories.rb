class CreateSpreeRefundHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_refund_histories do |t|
      t.string :reference_number
      t.decimal :amount, precision: 10, scale: 2
      t.belongs_to :user, index: true
      t.belongs_to :vendor, index: true

      t.timestamps
    end
  end
end
