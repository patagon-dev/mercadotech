Deface::Override.new(
  virtual_path: 'spree/admin/orders/_shipment_manifest',
  name: 'handle_exception_for_deleted_line_item',
  replace: "erb[loud]:contains('item.line_item.single_money.to_html')",
  text: '<%= item.line_item&.single_money&.to_html %>'
)

Deface::Override.new(
  virtual_path: 'spree/admin/orders/_shipment_manifest',
  name: 'handle_exception_for_deleted_line_item_price',
  replace: "erb[loud]:contains('line_item_shipment_price(item.line_item, item.quantity)')",
  text: '<%= line_item_shipment_price(item.line_item, item.quantity) if item.line_item.present? %>'
)
