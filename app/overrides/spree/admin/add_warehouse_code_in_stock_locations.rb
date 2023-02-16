Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'Add warehouse code field in stock location form',
  insert_before: 'div[data-hook="stock_location_address1"]',
  partial: 'spree/admin/shared/stock_location_fields'
)

Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'Add moova fields in stock location form',
  insert_before: 'div[data-hook="stock_location_address1"]',
  partial: 'spree/admin/shared/moova_fields'
)
