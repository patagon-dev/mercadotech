# This migration comes from spree_counties (originally 20140729200830)
class CreateSpreeCounties < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_counties do |t|
      t.string :name
      t.references :state, index: true

      t.timestamps
    end
  end
end
