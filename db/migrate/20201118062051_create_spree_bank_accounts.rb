class CreateSpreeBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_bank_accounts do |t|
      t.string :account_number
      t.string :name
      t.string :email
      t.string :rut
      t.boolean :is_default, default: false
      t.belongs_to :user, index: true
      t.belongs_to :bank, index: true

      t.timestamps
    end
  end
end
