class AddTransactionIdStatusToSpreeRefundHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_refund_histories, :transaction_id, :string
    add_column :spree_refund_histories, :status, :string
    add_column :spree_refund_histories, :failure_reason, :json
  end
end
