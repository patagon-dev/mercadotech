class CreateSpreeVendorTags < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_vendor_tags do |t|
      t.text :text
      t.string :color
      t.belongs_to :vendor
    end
  end
end
