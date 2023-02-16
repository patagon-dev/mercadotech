class AddFooterColumnNameFieldToSpreePages < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_pages, :footer_title, :integer, default: 0
  end
end
