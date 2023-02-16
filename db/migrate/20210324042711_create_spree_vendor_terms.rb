class CreateSpreeVendorTerms < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_vendor_terms do |t|
      t.string :name
      t.text :value
      t.belongs_to :vendor, index: true

      t.timestamps
    end
  end
end
