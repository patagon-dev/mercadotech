Deface::Override.new(
  virtual_path: 'spree/admin/stock_movements/index',
  name: 'Add button to generate stock location report',
  insert_after: "erb[loud]:contains('Spree.t(:new_stock_movement)')",
  original: '313f6b9dd374ea5b3da8d06858dc7c3cb8f85307',
  text: <<-HTML
                <%= button_link_to 'Stock Location Report', stock_location_report_admin_stock_location_path(@stock_location.id), icon: 'download', class: 'btn-primary' %>
  HTML
)
