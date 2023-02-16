# This migration comes from spree_multi_vende (originally 20210817071116)
class CreateSpreeCarrierPriorities < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_carrier_priorities do |t|
      t.string :carrier_name
      t.string :carrier_code
      t.integer :priority, null: false
      t.belongs_to :vendor, index: true

      t.timestamps
    end
  end
end
