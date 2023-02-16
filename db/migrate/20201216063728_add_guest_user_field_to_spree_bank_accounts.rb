class AddGuestUserFieldToSpreeBankAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_bank_accounts, :is_guest_user, :boolean, default: false
    add_column :spree_bank_accounts, :guest_user_email, :string
  end
end
