# This migration comes from spree_multi_vende (originally 20210812064050)
class CreateSpreeMultiVendeImports < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_multi_vende_imports do |t|
      t.string :service    # 'model_name'
      t.boolean :in_process
      t.belongs_to :merchant

      t.timestamps
    end
  end
end
