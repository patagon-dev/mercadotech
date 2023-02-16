class AddIsMoovFieldToSpreeZone < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_zones, :is_moova, :boolean, default: false
    add_column :spree_shipments, :moova_shipment_id, :string
  end
end
