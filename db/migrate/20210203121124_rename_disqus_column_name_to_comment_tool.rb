class RenameDisqusColumnNameToCommentTool < ActiveRecord::Migration[6.0]
  def change
    rename_column :spree_stores, :disqus, :comment_tool
  end
end
