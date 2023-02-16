class ResetStockItemsJob < ApplicationJob
  queue_as :import

  def perform(variant_ids)
    stock_location_ids = Spree::StockLocation.where(skip_from_import: false).pluck(:id)
    st_items = Spree::StockItem.where(variant_id: variant_ids, stock_location_id: stock_location_ids).where('count_on_hand > ?', 0)

    st_items.each do |item|
      item.update!(count_on_hand: 0)  # Expire in_stock_cache_key too
    rescue Exception => e
      puts "Error occured in updating stock: #{e}"
      next
    end
  end
end
