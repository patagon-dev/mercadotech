class AddEnviameReferenceToSpreeShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_shipments, :url_label, :string
    add_column :spree_shipments, :n_packages, :integer, default: 1
    add_reference :spree_shipments, :enviame_carrier, index: true
    add_reference :spree_shipments, :enviame_carrier_service, index: true
  end
end
