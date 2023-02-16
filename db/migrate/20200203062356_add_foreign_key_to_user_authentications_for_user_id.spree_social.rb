# This migration comes from spree_social (originally 20171028234629)
class AddForeignKeyToUserAuthenticationsForUserId < SpreeExtension::Migration[4.2]
  def change
    add_foreign_key :spree_user_authentications, :spree_users, column: :user_id
  end
end
