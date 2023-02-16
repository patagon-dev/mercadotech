Deface::Override.new(
  virtual_path: 'spree/admin/vendor_settings/product_import',
  name: 'Add spider manage tabs for full',
  insert_after: "erb[loud]:contains('from_full_scraping_hub')",
  partial: 'spree/admin/overrides/vendor_settings/full_spider_management'
)

Deface::Override.new(
  virtual_path: 'spree/admin/vendor_settings/product_import',
  name: 'Add spider manage tabs for small',
  insert_after: "erb[loud]:contains('from_quick_scraping_hub')",
  partial: 'spree/admin/overrides/vendor_settings/quick_spider_management'
)