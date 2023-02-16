class CreateSpreeEnviameCarrierServices < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_enviame_carrier_services do |t|
    	t.string :name
    	t.string :code
    	t.string :description
    	t.boolean :default
    	t.references :enviame_carrier, index: true

      t.timestamps
    end
  end
end
