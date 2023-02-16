module RedundantProduct
  extend ActiveSupport::Concern
  def duplicate_product_ids
    all_product_ids = @products.pluck(:id)
    uniq_product_ids = @products.sort_by(&:price).uniq(&:partnumber).pluck(:id)
    @duplicate_product_ids = all_product_ids - uniq_product_ids
  end
end
