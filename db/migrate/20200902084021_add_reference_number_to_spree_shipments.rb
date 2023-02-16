class AddReferenceNumberToSpreeShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_shipments, :reference_number, :string
  end
end
