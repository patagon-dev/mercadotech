# This migration comes from spree_multi_vende (originally 20210505064315)
class CreateSpreeHomologations < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_homologations do |t|
      t.string :on_local
      t.string :on_provider
      t.string :property_type
      t.belongs_to :vendor

      t.timestamps
    end
  end
end
