class CreateSpreeEnviameCarriers < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_enviame_carriers do |t|
      t.string :name
      t.string :code
      t.string :country

      t.timestamps
    end
  end
end
