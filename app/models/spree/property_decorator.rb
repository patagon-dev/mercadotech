module Spree::PropertyDecorator
  def self.prepended(base)
    base.after_save :reindex_products, if: :saved_change_to_filterable?
  end

  def reindex_products
    if filterable
      product_ids = products.pluck(:id)
      IndexerWorker.perform_async(:index, product_ids) if product_ids.any?
    end
  end

  Spree::Property.prepend self
end
