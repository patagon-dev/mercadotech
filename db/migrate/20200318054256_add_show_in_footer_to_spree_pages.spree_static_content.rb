# This migration comes from spree_static_content (originally 20170827000003)
class AddShowInFooterToSpreePages < SpreeExtension::Migration[4.2]
  def self.up
    add_column :spree_pages, :show_in_footer, :boolean, default: false, null: false
  end

  def self.down
    remove_column :spree_pages, :show_in_footer
  end
end
