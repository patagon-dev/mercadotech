Deface::Override.new(
  virtual_path: 'spree/admin/orders/_shipment',
  name: 'update_logic_to_show_ship_button',
  replace: "erb[silent]:contains('shipment.ready? and can? :update, shipment')",
  text: '<% if shipment.ready_to_ship? and can? :update, shipment %>'
)
