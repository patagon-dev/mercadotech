Deface::Override.new(
  virtual_path: 'spree/admin/users/_form',
  name: 'Add rut field in user form',
  insert_bottom: 'div[data-hook="admin_user_form_password_fields"]',
  partial: 'spree/admin/shared/rut_field'
)

Deface::Override.new(
  virtual_path: 'spree/admin/users/_form',
  name: 'Add new fields in user form',
  insert_after: 'div[data-hook="admin_user_form_fields"]',
  partial: 'spree/admin/shared/user_fields'
)
