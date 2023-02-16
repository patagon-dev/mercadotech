spree_version = Gem.loaded_specs['spree_core'].version
unless spree_version >= Gem::Version.create('3.3.0') && spree_version < Gem::Version.create('3.5.0') && spree_version != Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(virtual_path: 'spree/layouts/spree_application',
                       name: 'add_gtm_body_to_layouts',
                       insert_top: "[data-hook='body']",
                       partial: 'spree/shared/trackers/google_tag_manager/body.js')
end
