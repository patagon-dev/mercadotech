class AddFieldsToSpreeUsersAndVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_users, :codigo, :string
    add_column :spree_users, :nombres, :string
    add_column :spree_users, :apellidos, :string
    add_column :spree_users, :telefono, :string
    add_column :spree_users, :celular, :string
    add_column :spree_users, :organismo, :string
    add_column :spree_users, :unidad, :string
    add_column :spree_users, :rut_unidad, :string
    add_column :spree_users, :direccion, :string
    add_column :spree_users, :citName, :string
    add_column :spree_users, :disName, :string
    add_column :spree_vendors, :ticket_id, :string
    add_column :spree_vendors, :tax_id, :string
    add_column :spree_vendors, :address, :string
  end
end
