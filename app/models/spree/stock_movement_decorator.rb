module Spree::StockMovementDecorator
  private

  def update_stock_item_quantity
    return unless stock_item.should_track_inventory?
    return if stock_item.variant.by_pass_stock

    stock_item.adjust_count_on_hand quantity
  end

  ::Spree::StockMovement.prepend self
end
