Deface::Override.new(
  virtual_path: 'spree/admin/stores/_form',
  name: 'add addition fields to store form',
  insert_bottom: 'div[data-hook="admin_store_form_fields"]',
  partial: 'spree/admin/shared/additional_fields_store'
)
