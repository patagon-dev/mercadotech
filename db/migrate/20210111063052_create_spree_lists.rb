class CreateSpreeLists < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_lists do |t|
      t.string :key
      t.string :name
      t.integer :subscribers_count, default: 0
      t.boolean :default_list, default: false
      t.belongs_to :store, index: true

      t.timestamps
    end
  end
end
