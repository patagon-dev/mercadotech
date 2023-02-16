object @vendor
attributes(*vendor_attributes)

node(:active_warehouses) { |v| v.stock_locations.active.pluck(:admin_name) }
node(:vendor_type) { |v| v.vendor_type }
node(:merchant_id) { |v| v.merchant&.merchant_id}
