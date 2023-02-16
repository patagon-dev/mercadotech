class AddDisqusToSpreeStore < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stores, :disqus, :text
  end
end
