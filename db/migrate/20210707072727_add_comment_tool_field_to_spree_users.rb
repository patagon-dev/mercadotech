class AddCommentToolFieldToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :comment_tool_signup, :boolean, default: false
  end
end
