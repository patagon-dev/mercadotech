module Spree::VendorAbilityDecorator
  def initialize(user)
    super
    @user ||= user
    @vendor_ids = user.vendors.active.ids
    if @vendor_ids.any?
      apply_custom_shipping_permissions
      apply_invoice_permissions
      apply_payment_permissions
      apply_additional_order_permissions
      apply_shipping_categories_permissions
    end
  end

  private

  def apply_custom_shipping_permissions
    can %i[admin get_services create_shipment_delivery mark_payment_refunded remove_shipping_label make_refund], Spree::Order
  end

  def apply_invoice_permissions
    can :manage, Spree::Invoice
  end

  def apply_payment_permissions
    can :create, Spree::Payment
    can %i[admin index show capture fire mark_payment_refunded make_refund], Spree::Payment, vendor_id: @vendor_ids
  end

  def apply_additional_order_permissions
    can %i[modify cart], Spree::Order
    can %i[index show fire generate_pickup_list generate_purchase_list shipment_details store set_store], Spree::Order, line_items: { product: { vendor_id: @vendor_ids } }
    can :modify, Spree::LineItem, { product: { vendor_id: @vendor_ids } }
    can :manage, [Spree::Adjustment, Spree::ReturnItem, Spree::Reimbursement, Spree::Refund, Spree::BankAccount, :return_index]
    can :manage, [Spree::ReturnAuthorization, Spree::CustomerReturn], vendor_id: @vendor_ids
    can :create, [Spree::ReturnAuthorization, Spree::CustomerReturn]
    can :modify, [Spree::Address, Spree::Shipment]
    can %i[edit show], Spree::User
    cannot :manage, Spree::AuthenticationMethod
    can :read, [Spree::Store, Spree::ReimbursementType]
  end

  def apply_shipping_categories_permissions
    can :manage, Spree::ShippingCategory, vendor_id: @vendor_ids
    cannot [:create, :edit, :destroy], Spree::ShippingCategory
  end

  def apply_variant_permissions
    super
    can :show, Spree::Variant
  end
  Spree::VendorAbility.prepend self
end
