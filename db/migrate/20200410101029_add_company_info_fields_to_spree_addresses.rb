class AddCompanyInfoFieldsToSpreeAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_addresses, :company_rut, :string
    add_column :spree_addresses, :company_business, :string
    add_column :spree_addresses, :street_number, :string
  end
end
