Deface::Override.new(
  virtual_path: 'spree/admin/stores/_form',
  name: 'Add login types in store form',
  insert_after: 'div[data-hook="tax_on_checkout"]',
  partial: 'spree/admin/shared/login_types'
)

Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_stores_to_admin_menu',
  remove: "erb[silent]:contains('Spree.t(:stores_admin)')",
  closing_selector: "erb[silent]:contains('spree.admin_stores_url')"
)

Deface::Override.new(
  virtual_path: 'spree/admin/stores/_form',
  name: 'Add invoice_types in store form',
  insert_before: 'div[data-hook="tax_on_checkout"]',
  partial: 'spree/admin/shared/invoice_types'
)
