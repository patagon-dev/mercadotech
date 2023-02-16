class AddPhoneFieldIntoSpreeVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :phone, :string
  end
end
