class AddKhipuFieldsIntoSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :enable_khipu, :boolean
    add_column :spree_vendors, :khipu_id, :string
    add_column :spree_vendors, :khipu_secret, :string
  end
end
