module Spree::VendorDecorator
  def self.prepended(base)
    base.include Spree::VendorEnums
    base.extend Spree::DisplayMoney
    base.validates_with RutValidator
    base.validates :scrapinghub_api_key, :scrapinghub_project_id, :full_spider, :quick_spider, presence: true, if: lambda {
                                                                                                                     scrapinghub?
                                                                                                                   }
    base.validates :superfactura_login, :superfactura_password, :superfactura_environment, presence: true, if: lambda {
                                                                                                                 superfactura_api?
                                                                                                               }
    base.validates :bank_transfer_url, :bank_transfer_login, :bank_transfer_password, presence: true, if: lambda {
                                                                                                            enable_bank_transfer?
                                                                                                          }
    base.validates :moova_api_key, :moova_api_secret, presence: true, if: -> { enable_moova? }
    base.validates :minimum_order_value, presence: true, if: -> { set_minimum_order? }
    base.serialize :import_store_ids, Array
    base.money_methods :minimum_order_value
    base.before_save :formatted_rut
    base.has_and_belongs_to_many :enviame_carriers
    base.has_many :tags, class_name: 'Spree::VendorTag'
    base.accepts_nested_attributes_for :tags
    base.has_many :vendor_terms, class_name: 'Spree::VendorTerm'
    base.accepts_nested_attributes_for :vendor_terms
    base.after_create :assign_default_shipping_categories
    base.has_many_attached :scrapinghub_error_files
  end

  def line_item_total(order)
    order.line_items.for_vendor(self).map(&:final_amount).sum.round
  end

  def shipment_total(order)
    order.shipments.for_vendor(self).map(&:final_price).sum.round
  end

  def total_amount(order)
    line_item_total(order) + shipment_total(order)
  end

  def is_active?
    state == 'active'
  end

  def assign_default_shipping_categories
    %w[small medium large extra_large].each do |category|
      Spree::ShippingCategory.create(name: category, vendor_id: id)
    end
  end

  def vendor_type
    merchant.present? ? merchant.merchant_type : 'normal'
  end

  private

  def formatted_rut
    self.rut = Rut.formatear(rut) if rut.present?
  end

  Spree::Vendor.prepend self
end
