class RemoveApprovedFieldFromSpreeReturnAuthorization < ActiveRecord::Migration[6.0]
  def change
    remove_column :spree_return_authorizations, :approved, :boolean, default: false
    add_column :spree_stores, :show_included_tax, :boolean, default: false
  end
end
