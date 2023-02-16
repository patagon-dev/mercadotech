class AddPaymentMethodTypeToSpreeRefundHistories < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_refund_histories, :refund_type, :string
    add_index :spree_refund_histories, :reference_number
  end
end
