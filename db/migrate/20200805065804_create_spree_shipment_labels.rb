class CreateSpreeShipmentLabels < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_shipment_labels do |t|
      t.string :tracking_number
      t.string :label_url
      t.belongs_to :shipment

      t.timestamps
    end

    Rake::Task['enviame_label:migrate'].invoke

    remove_column :spree_shipments, :url_label, :string
  end
end
