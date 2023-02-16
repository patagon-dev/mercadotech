module Spree
  module Stock
    module EstimatorDecorator
      private

      def shipping_methods(package, display_filter)
        package.shipping_methods.select do |ship_method|
          calculator = ship_method.calculator

          ship_method.available_to_display?(display_filter) &&
            (ship_method.shipping_categories - package.shipping_categories).empty? &&
            ship_method.include?(order.ship_address) &&
            calculator.available?(package) &&
            (calculator.preferences[:currency].blank? ||
             calculator.preferences[:currency] == currency)
        end
      end

    ::Spree::Stock::Estimator.prepend self
    end
  end
end
