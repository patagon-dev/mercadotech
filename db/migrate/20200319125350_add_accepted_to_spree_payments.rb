class AddAcceptedToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column(:spree_payments, :accepted, :boolean) unless column_exists?(:spree_payments, :accepted)
  end
end

