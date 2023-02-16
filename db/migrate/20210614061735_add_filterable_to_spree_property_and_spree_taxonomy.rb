class AddFilterableToSpreePropertyAndSpreeTaxonomy < ActiveRecord::Migration[6.1]
  def change
    Spree::Property.where(filterable: nil).update_all(filterable: false) # updating existing records

    change_column :spree_properties, :filterable, :boolean, default: false, null: false
    add_column :spree_taxonomies, :filterable, :boolean, default: false, null: false
  end
end
