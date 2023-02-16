spree_version = Gem.loaded_specs['spree_core'].version
unless spree_version >= Gem::Version.create('3.3.0') && spree_version < Gem::Version.create('3.5.0') && spree_version != Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/shared/_head',
    name: 'add_gtm_intializer_to_head',
    insert_after: 'title',
    partial: 'spree/shared/trackers/google_tag_manager/initializer.js'
  )
end