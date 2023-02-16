# This migration comes from spree_multi_domain (originally 20130308084714)
class AddLogoToStores < SpreeExtension::Migration[4.2]
  def self.up
    change_table :spree_stores do |t|
      t.string :logo_file_name
    end
  end

  def self.down
    change_table :spree_stores do |t|
      t.remove :logo_file_name
    end
  end
end
