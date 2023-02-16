class AddPackageSizeToSpreeShipments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_shipments, :package_size, :integer
  end
end
