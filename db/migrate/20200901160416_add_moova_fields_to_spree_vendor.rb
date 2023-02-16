class AddMoovaFieldsToSpreeVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :enable_moova, :boolean, default: false
    add_column :spree_vendors, :moova_api_key, :string
    add_column :spree_vendors, :moova_api_secret, :string
  end
end
