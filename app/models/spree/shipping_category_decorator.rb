module Spree::ShippingCategoryDecorator
  def self.prepended(base)
    base.clear_validators!
    base.validates :name, presence: true
    begin
      return unless Spree::Vendor.table_exists?
    rescue StandardError
      nil
    end

    base.validates :vendor_id, presence: true
    base.validates_with NameValidator
    base.before_save :prepend_vendor_id, if: :name_changed?
  end

  def name_without_prefix
    name.split('_', 2)[1]
  end

  private

  def prepend_vendor_id
    name.prepend("#{vendor_id}_")
  end

  Spree::ShippingCategory.prepend self
end
