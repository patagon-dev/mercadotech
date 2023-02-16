# Customer purchase detail to order tabs
Deface::Override.new(
  virtual_path: 'spree/admin/orders/edit',
  name: 'Add customer purchased orders in admin orders',
  insert_before: 'div[data-hook="admin_order_edit_form"]',
  partial: 'spree/admin/shared/customer_purchased_orders'
)

# Invoices to order tabs
Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'Add invoices to orders tab',
  insert_bottom: 'ul[data-hook="admin_order_tabs"]',
  partial: 'spree/admin/shared/invoices_tab'
)

# Reference order numbers
Deface::Override.new(
  virtual_path: 'spree/admin/orders/edit',
  name: 'Add reference order numbers in admin orders',
  insert_after: 'div[data-hook="admin_order_edit_form"]',
  partial: 'spree/admin/shared/reference_order_numbers'
)

# Customer Bank to order tabs
Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'Add bank account to orders tab',
  insert_bottom: 'ul[data-hook="admin_order_tabs"]',
  partial: 'spree/admin/shared/bank_account_tab'
)
