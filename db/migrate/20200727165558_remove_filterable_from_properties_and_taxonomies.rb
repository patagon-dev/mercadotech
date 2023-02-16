class RemoveFilterableFromPropertiesAndTaxonomies < ActiveRecord::Migration[6.0]
  def change
    remove_column :spree_properties, :filterable, :boolean
    remove_column :spree_taxonomies, :filterable, :boolean
  end
end
