# This migration comes from spree_slider (originally 20150611113500)
class CreateSliderLocation < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_slide_locations do |t|
      t.string :name
      t.timestamps
    end

    create_table :spree_slide_slide_locations do |t|
      t.belongs_to :slide, index: true
      t.belongs_to :slide_location, index: true
    end
  end
end
