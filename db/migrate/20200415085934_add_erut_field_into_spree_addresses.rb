class AddErutFieldIntoSpreeAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_addresses, :e_rut, :string
  end
end
