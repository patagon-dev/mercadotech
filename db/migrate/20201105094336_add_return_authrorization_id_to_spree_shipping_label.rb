class AddReturnAuthrorizationIdToSpreeShippingLabel < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_shipment_labels, :return_authorization_id, :integer
  end
end
