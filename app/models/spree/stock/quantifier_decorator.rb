module Spree::Stock::QuantifierDecorator
  def can_supply?(required = 1)
    (variant.available? && (total_on_hand >= required || backorderable?)) || variant.by_pass_stock
  end

  ::Spree::Stock::Quantifier.prepend self
end
