# This migration comes from spree_static_content (originally 20160217113416)
class RemoveShowInFooterFromSpreePages < SpreeExtension::Migration[4.2]
  def self.up
    remove_column :spree_pages, :show_in_footer
  end

  def self.down
    add_column :spree_pages, :show_in_footer, :boolean, default: false, null: false
  end
end
