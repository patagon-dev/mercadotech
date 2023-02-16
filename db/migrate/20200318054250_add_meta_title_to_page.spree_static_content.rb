# This migration comes from spree_static_content (originally 20110717103112)
class AddMetaTitleToPage < SpreeExtension::Migration[4.2]
  def self.up
    add_column :spree_pages, :meta_title, :string
  end

  def self.down
    remove_column :spree_pages, :meta_title
  end
end
