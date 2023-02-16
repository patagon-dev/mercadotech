class AddProductXmlUrlToSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :products_xml_url, :string
    add_column :spree_vendors, :products_xml_imported_at, :datetime
  end
end
