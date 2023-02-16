class AddHeadScriptToSpreePage < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_pages, :head_scripts, :text
  end
end
