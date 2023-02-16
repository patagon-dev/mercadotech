# This migration comes from spree_searchkick (originally 20200714133927)
class AddFilterableToSpreeOptionTypes < ActiveRecord::Migration[6.0]
  def change
    unless column_exists?(:spree_option_types, :filterable)
      add_column :spree_option_types, :filterable, :boolean unless column_exists?(:spree_option_types, :filterable)
    end
    unless index_exists?(:spree_option_types, :filterable)
      add_index :spree_option_types, :filterable
    end
  end
end
