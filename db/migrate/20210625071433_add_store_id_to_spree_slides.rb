class AddStoreIdToSpreeSlides < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_slides, :store_id, :integer
  end
end
