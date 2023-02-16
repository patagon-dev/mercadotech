class AddUpdateProductCheckToSpreeVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :update_all_product, :boolean, default: false
  end
end
