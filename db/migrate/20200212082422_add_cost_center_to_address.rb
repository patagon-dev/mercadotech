class AddCostCenterToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_addresses, :unidad, :string
  end
end
