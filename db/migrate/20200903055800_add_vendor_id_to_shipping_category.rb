class AddVendorIdToShippingCategory < ActiveRecord::Migration[6.0]
  def change
  	add_column :spree_shipping_categories, :vendor_id, :integer
  end
end
