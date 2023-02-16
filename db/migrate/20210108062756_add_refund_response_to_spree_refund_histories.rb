class AddRefundResponseToSpreeRefundHistories < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_refund_histories, :refund_response, :json
  end
end
