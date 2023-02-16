class AddPickupGeneratedToSpreeReturnAuthorization < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_return_authorizations, :pickup_generated, :boolean, default: false
  end
end
