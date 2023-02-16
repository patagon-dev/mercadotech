class AddNameFieldToSpreeVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_variants, :name, :string
  end
end
