# This migration comes from spree_multi_vende (originally 20210426054026)
class CreateSpreeMultivendes < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_multivendes do |t|
      t.string :client_id
      t.string :client_secret
      t.belongs_to :store

      t.timestamps
    end
  end
end

