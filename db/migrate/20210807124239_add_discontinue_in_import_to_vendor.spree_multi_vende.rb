# This migration comes from spree_multi_vende (originally 20210807123514)
class AddDiscontinueInImportToVendor < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :discontinue_in_import, :boolean, default: true
  end
end
