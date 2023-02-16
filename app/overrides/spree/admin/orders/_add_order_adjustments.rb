Deface::Override.new(
  virtual_path: 'spree/admin/orders/_form',
  name: 'remove_admin_order_adjustments',
  remove: "erb[loud]:contains('spree/admin/orders/adjustments')",
  closing_selector: "erb[loud]:contains('Spree.t(:order_adjustments)')"
)

Deface::Override.new(
  virtual_path: 'spree/admin/orders/_line_items_edit_form',
  name: 'remove_admin_order_line_item_adjustments',
  remove: "erb[loud]:contains('spree/admin/orders/adjustments')",
  closing_selector: "erb[loud]:contains('Spree.t(:order_adjustments)')"
)

Deface::Override.new(
  virtual_path: 'spree/admin/orders/_form',
  name: 'Add adjustments in admin orders',
  insert_before: 'div[data-hook="order_details_total"]',
  partial: 'spree/admin/shared/order_total_adjustments'
)

Deface::Override.new(
  virtual_path: 'spree/admin/orders/_line_items_edit_form',
  name: 'Add adjustments in admin orders',
  insert_before: 'div[data-hook="order_details_total"]',
  partial: 'spree/admin/shared/order_total_adjustments'
)
