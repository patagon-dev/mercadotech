class AddUserInitiatedToReturnAuthorizations < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_return_authorizations, :user_initiated, :boolean, default: false
    add_column :spree_return_authorizations, :approved, :boolean, default: false
  end
end
