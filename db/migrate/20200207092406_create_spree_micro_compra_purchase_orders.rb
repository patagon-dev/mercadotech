class CreateSpreeMicroCompraPurchaseOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_micro_compra_purchase_orders do |t|
      t.string :fecha_respuesta
      t.string :codigo_respuesta
      t.string :respuesta
      t.string :url
      t.references :order, index: true
      t.references :vendor, index: true
      t.timestamps
    end
  end
end
