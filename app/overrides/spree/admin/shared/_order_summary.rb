Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'display_vendor_total',
  replace: "erb[loud]:contains('@order.display_total.to_html')",
  text: '<%= current_spree_vendor ? @order.display_vendor_specific_total(current_spree_vendor).to_html : @order.display_total.to_html %>'
)

Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'display_vendor_ship_total',
  replace: "erb[loud]:contains('@order.display_ship_total.to_html')",
  text: '<%= current_spree_vendor ? @order.display_vendor_specific_ship_total(current_spree_vendor).to_html : @order.display_ship_total.to_html %>'
)

Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'display_tax_included_total',
  replace: "erb[loud]:contains('@order.display_included_tax_total.to_html')",
  text: '<%= current_spree_vendor ? @order.display_vendor_included_tax_total(current_spree_vendor).to_html : @order.display_included_tax_total.to_html %>'
)

Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'display_tax_additional_total',
  replace: "erb[loud]:contains('@order.display_additional_tax_total.to_html')",
  text: '<%= current_spree_vendor ? @order.display_vendor_additional_tax_total(current_spree_vendor).to_html : @order.display_additional_tax_total.to_html %>'
)
