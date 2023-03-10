object @order
extends 'spree/api/v1/orders/order'
@vendor_line_items = @order.line_items_per_vendor(@current_api_user)
@vendor_payments = @order.payment_per_vendor(@current_api_user)
@vendor_shipments = @order.shipments_per_vendor(@current_api_user)

if lookup_context.find_all("spree/api/v1/orders/#{root_object.state}").present?
  extends "spree/api/v1/orders/#{root_object.state}"
end

child billing_address: :bill_address do
  extends 'spree/api/v1/addresses/show'
end

child shipping_address: :ship_address do
  extends 'spree/api/v1/addresses/show'
end

child @vendor_line_items => :line_items do
  extends 'spree/api/v1/line_items/show'
end

child @vendor_payments => :payments do
  attributes(*payment_attributes)

  child payment_method: :payment_method do
    attributes :id, :name
  end

  child source: :source do
    if @current_user_roles.include?('admin')
      attributes(*payment_source_attributes + %i[gateway_customer_profile_id gateway_payment_profile_id])
    else
      attributes(*payment_source_attributes)
    end
  end
end

child @vendor_shipments => :shipments do
  extends 'spree/api/v1/shipments/small'
end

child adjustments: :adjustments do
  extends 'spree/api/v1/adjustments/show'
end

# Necessary for backend's order interface
node :permissions do
  { can_update: current_ability.can?(:update, root_object) }
end

child valid_credit_cards: :credit_cards do
  extends 'spree/api/v1/credit_cards/show'
end
