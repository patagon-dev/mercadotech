class CreateSpreeEnviameCarriersVendors < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_enviame_carriers_vendors do |t|
      t.belongs_to :enviame_carrier
      t.belongs_to :vendor
    end
  end
end
