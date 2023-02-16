# This migration comes from spree_searchkick (originally 20200901123644)
class AddFiltersToFilterable < ActiveRecord::Migration[6.0]
  def change
    add_index :spree_taxonomies, :filterable unless index_exists?(:spree_taxonomies, :filterable)
    add_index :spree_properties, :filterable unless index_exists?(:spree_properties, :filterable)
    add_index :spree_option_types, :filterable unless index_exists?(:spree_option_types, :filterable)
  end
end
