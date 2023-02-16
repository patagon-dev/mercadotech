module Spree::ProductDecorator
  Spree::Product.whitelisted_ransackable_associations += %w[taxons shipping_category]

  def self.prepended(base)
    base.has_many :relation_types, class_name: 'Spree::RelationType', through: :relations
    base.after_update :set_vendor, if: :saved_change_to_vendor_id?
    base.whitelisted_ransackable_attributes = %w[partnumber etilize_id]
    base.has_many_attached :datasheet_files
    base.after_commit :set_default_product_property, on: :create
    base.has_many :reviews

    def base.relation_filter
      set = super
      set.joins(:stock_items).where('spree_stock_items.count_on_hand > 0')
         .distinct
    end
  end

  def has_active_vendor?
    vendor&.is_active?
  end

  def has_variants?
    variants.active.any?
  end

  def formatted_sku
    sku.split('_', 2).last rescue ''
  end

  def competitor_prices_ability(store_code)
    store_code == 'mercadotech' && solotodo_id.present?
  end

  private

  def set_vendor
    master.update(vendor_id: vendor_id)
    variants.update(vendor_id: vendor_id)
  end

  def set_default_product_property
    dp = Spree::Property.find_or_create_by(name: 'manufacturer', presentation: 'manufacturer', vendor_id: vendor_id)
    self.product_properties.find_or_create_by(property_id: dp.id) # creating default product property
  end
end

::Spree::Product.prepend(Spree::ProductDecorator)