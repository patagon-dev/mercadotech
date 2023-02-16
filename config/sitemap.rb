stores = Spree::Store.all

stores.each do |store|
  uri = URI.parse(store.url)
  SitemapGenerator::Sitemap.default_host = uri.scheme.present? ? uri.to_s : "https://#{uri}"
  SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
  SitemapGenerator::Sitemap.filename = store.code
  SitemapGenerator::Sitemap.create do
    # Put links creation logic here.
    #
    # The root path '/' and sitemap index file are added automatically.
    # Links are added to the Sitemap in the order they are specified.
    #
    # Usage: add(path, options = {})
    #        (default options are used if you don't specify)
    #
    # Defaults: priority: 0.5, changefreq: 'weekly',
    #           lastmod: Time.now, host: default_host
    #
    #
    # Examples:
    #
    # Add '/articles'
    #
    #   add articles_path, priority: 0.7, changefreq: 'daily'
    #
    # Add individual articles:
    #
    #   Article.find_each do |article|
    #     add article_path(article), lastmod: article.updated_at
    #   end
    # add_login
    # add_signup
    # add_account
    # add_password_reset

    # Add store specific taxons
    options = {}
    Spree::Taxon.roots.where(taxonomy_id: store.taxonomies.pluck(:id)).each { |taxon| add_taxon(taxon, options) }

    # Add store specific products
    options = {}
    active_products = store.products.active.distinct

    add(products_path, options.merge(lastmod: active_products.last_updated))
    active_products.find_each do |product|
      add_product(product, options)
    end
  end
end
