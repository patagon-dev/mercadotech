class AddProductsCsvUrlIntoVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :products_csv_url, :string
    add_column :spree_vendors, :products_imported_at, :datetime
  end
end
