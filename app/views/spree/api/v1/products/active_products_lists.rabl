object @product
cache [I18n.locale, @current_user_roles.include?('admin'), current_currency, root_object]

node(:id) { |p| p.id }
node(:partnumber) { |p| p.partnumber }
node(:etilize_id) { |p| p.etilize_id }
node(:vendor_id) { |p| p.vendor_id }
node(:sku) { |p| p.sku.split('_', 2)[1] }
node(:solotodo_id) { |p| p.solotodo_id }