class AddFilterableToSpreeProperties < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_properties, :filterable, :boolean
  end
end
