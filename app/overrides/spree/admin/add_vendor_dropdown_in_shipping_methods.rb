Deface::Override.new(
  virtual_path: 'spree/admin/shipping_methods/_form',
  name: 'Add vendor dropdown in shipping method form',
  insert_after: 'div[data-hook="admin_shipping_method_form_calculator_fields"]',
  partial: 'spree/admin/shared/shipping_methods_fields'
)
