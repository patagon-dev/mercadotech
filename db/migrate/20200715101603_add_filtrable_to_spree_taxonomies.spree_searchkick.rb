# This migration comes from spree_searchkick (originally 20150819222417)
class AddFiltrableToSpreeTaxonomies < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_taxonomies, :filterable, :boolean
  end
end
