class AddBankTransferFieldToSpreeVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_vendors, :enable_bank_transfer, :boolean, default: false
    add_column :spree_vendors, :bank_transfer_url, :string
    add_column :spree_vendors, :bank_transfer_login, :string
    add_column :spree_vendors, :bank_transfer_password, :string
  end
end
