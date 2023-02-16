class CreateSpreeInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_invoices do |t|
      t.string :number
      t.belongs_to :payment

      t.timestamps
    end
  end
end
