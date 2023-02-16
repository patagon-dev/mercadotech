class CreateSpreeSpiderManagements < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_spider_managements do |t|
      t.string :job_id
      t.string :spider_name
      t.string :items
      t.string :requests
      t.string :close_reason
      t.string :finished
      t.belongs_to :vendor

      t.timestamps
    end
  end
end
