class AddRutFieldToSpreeUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_users, :rut, :string
  end
end
