class Spree::StoreAdminAbility
  include CanCan::Ability

  def initialize(user)
    @store_id = user.store_ids

    if @store_id.present?
      apply_general_permissions
      apply_order_permissions
      apply_image_permissions
      apply_product_permissions
      apply_stock_movement_permissions
      apply_vendor_permissions
      apply_shipping_methods_permissions
      apply_shipping_categories_permissions
      apply_stock_locations_permissions
      apply_return_authorization_permissions
      apply_customer_return_permissions
      apply_property_permissions
      apply_product_property_permissions
      apply_shipment_permissions
      apply_stock_items_permissions
      apply_invoices_permissions
      apply_line_items_permissions
    end
  end

  private

  def apply_general_permissions
    can %i[admin index manage create modify], [Spree::Promotion, Spree::Page, Spree::Classification, Spree::OptionType, Spree::Price, Spree::ProductOptionType, Spree::Stock, Spree::Variant, Spree::StateChange, Spree::AuthenticationMethod, Spree::Adjustment, Spree::ReimbursementType, Spree::Reimbursement, Spree::ReturnItem, Spree::Refund, Spree::Address]
  end

  def apply_order_permissions
    can %i[manage index cart payments show fire generate_pickup_list generate_purchase_list shipment_details store set_store return_authorizations return_index update admin get_services create_shipment_delivery mark_payment_refunded remove_shipping_label], Spree::Order, store_id: @store_id
    can %i[create admin], Spree::Order
    can %i[read admin], Spree::Store
  end

  def apply_image_permissions
    can :create, Spree::Image

    can [:manage, :modify, :admin], Spree::Image do |image|
      image.viewable_type == 'Spree::Variant'
    end
  end

  def apply_product_permissions
    cannot_display_model(Spree::Product)
    can %i[create admin], Spree::Product
    can %i[manage modify stock related], Spree::Product, stores: { id: @store_id }
  end

  def apply_stock_movement_permissions
    can %i[manage admin], Spree::StockMovement, stock_item: { stock_location: { vendor: { products: { stores: { id: @store_id } } } } }
    can :create, Spree::StockMovement
  end

  def apply_vendor_permissions
    can %i[create admin], Spree::Vendor
    can %i[manage modify tags payments shipping invoice product_import], Spree::Vendor, products: { stores: { id: @store_id } }
  end

  def apply_shipping_methods_permissions
    can :manage, Spree::ShippingMethod, vendor: { products: { stores: { id: @store_id } } }
    can :create, Spree::ShippingMethod
  end

  def apply_shipping_categories_permissions
    can %i[manage index], Spree::ShippingCategory, shipping_methods: { vendor: { products: { stores: { id: @store_id } } } }
    can %i[create admin], Spree::ShippingCategory
  end

  def apply_stock_locations_permissions
    can :manage, Spree::StockLocation, vendor: { products: { stores: { id: @store_id } } }
    can %i[create admin], Spree::StockLocation
  end

  def apply_return_authorization_permissions
    can :manage, Spree::ReturnAuthorization, stock_location: { vendor: { products: { stores: { id: @store_id } } } }
    can %i[create admin], Spree::ReturnAuthorization
  end

  def apply_customer_return_permissions
    can :manage, Spree::CustomerReturn, stock_location: { vendor: { products: { stores: { id: @store_id } } } }
    can %i[create admin], Spree::CustomerReturn
  end

  def apply_property_permissions
    can :manage, Spree::Property, vendor: { products: { stores: { id: @store_id } } }
    can %i[create admin], Spree::Property
  end

  def apply_product_property_permissions
    can :manage, Spree::ProductProperty, product: { stores: { id: @store_id } }
    can %i[create admin], Spree::ProductProperty
  end

  def apply_shipment_permissions
    can :manage, Spree::Shipment, order: { products: { stores: { id: @store_id } } }
    can %i[create admin], Spree::Shipment
  end

  def apply_stock_items_permissions
    can :manage, Spree::StockItem, stock_location: { vendor: { products: { stores: { id: @store_id } } } }
    can %i[create admin], Spree::StockItem
  end

  def apply_invoices_permissions
    can :manage, Spree::Invoice, vendor: { products: { stores: { id: @store_id } } }
    can %i[create admin], Spree::Invoice
  end

  def apply_line_items_permissions
    can :manage, Spree::LineItem, product: { stores: { id: @store_id } }
    can %i[create admin], Spree::LineItem
  end

  def apply_payment_permissions
    can :manage, Spree::Payment, vendor: { products: { stores: { id: @store_id } } }
    can %i[create admin], Spree::Payment
  end

  def cannot_display_model(model)
    Spree.version.to_f < 4.0 ? (cannot :display, model) : (cannot :read, model)
  end
end
