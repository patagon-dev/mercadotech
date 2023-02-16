class AddedRefundTypeToSpreeRefund < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_refunds, :refund_type, :string
  end
end
