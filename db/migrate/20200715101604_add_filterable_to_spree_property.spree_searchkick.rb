# This migration comes from spree_searchkick (originally 20151009155442)
class AddFilterableToSpreeProperty < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_properties, :filterable, :boolean
  end
end
