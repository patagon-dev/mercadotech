module Spree
  module TaxonsControllerDecorator
    include RedundantProduct
    def product_carousel
      if !http_cache_enabled? || stale?(etag: carousel_etag, last_modified: last_modified, public: true)
        load_products
        if @products.any?
          render template: 'spree/taxons/product_carousel', layout: false
        else
          head :no_content
        end
      end
    end

  private

    def load_products
      super
      duplicate_product_ids
    end
  end
end
::Spree::TaxonsController.prepend Spree::TaxonsControllerDecorator
