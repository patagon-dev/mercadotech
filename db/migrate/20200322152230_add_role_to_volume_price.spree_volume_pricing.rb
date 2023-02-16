# This migration comes from spree_volume_pricing (originally 20150513200904)
class AddRoleToVolumePrice < SpreeExtension::Migration[4.2]
  def change
    add_column :spree_volume_prices, :role_id, :integer
  end
end
