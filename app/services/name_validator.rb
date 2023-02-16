class NameValidator < ActiveModel::Validator
  def validate(record)
    shipping_category = Spree::ShippingCategory.where(name: "#{record.vendor_id}_#{record.name}").take
    record.errors[:name] << Spree.t(:already_in_use) if shipping_category.present?
  end
end
