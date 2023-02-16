require 'digest'

module Spree
  module NavigationHelperDecorator
    def spree_footer_data
      @spree_footer_data ||= Spree::Page.by_store(current_store).visible.footer_links.pluck(:slug) || []
    # safeguard for older Spree installs that don't have spree_navigation initializer
    # or spree.yml file present
    rescue
      []
    end

    def spree_footer_cache_key(section = 'footer')
      @spree_footer_cache_key = begin
        keys = base_cache_key + [current_store.id, spree_footer_data_cache_key, Spree::Config[:logo], stores&.cache_key, section]
        Digest::MD5.hexdigest(keys.join('-'))
      end
    end

    def spree_nav_cache_key(section = 'footer')
      @spree_nav_cache_key = begin
        keys = base_cache_key + [current_store.id, spree_navigation_data_cache_key, Spree::Config[:logo], stores&.cache_key, section]
        Digest::MD5.hexdigest(keys.join('-'))
      end
    end

    private

    def spree_footer_data_cache_key
      @spree_footer_data_cache_key ||= Digest::MD5.hexdigest(spree_footer_data.to_s)
    end
  end
end

::Spree::NavigationHelper.prepend Spree::NavigationHelperDecorator