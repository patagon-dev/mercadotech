spree_version = Gem.loaded_specs['spree_core'].version
unless spree_version >= Gem::Version.create('3.3.0') && spree_version < Gem::Version.create('3.5.0') && spree_version != Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/orders/show',
    name: 'add_purchase_event_to_show_order',
    insert_after: "erb[silent]:contains('if order_just_completed?(@order)')",
    partial: 'spree/shared/trackers/google_tag_manager/purchase.js'
  )
end