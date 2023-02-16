class RemoveAddressColumnsFromUserTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :spree_users, :direccion
    remove_column :spree_users, :citName
    remove_column :spree_users, :disName
    remove_column :spree_users, :unidad
  end
end
