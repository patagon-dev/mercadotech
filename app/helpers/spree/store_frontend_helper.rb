module Spree
  module StoreFrontendHelper
    def new_price_filter_values
      [
        "#{I18n.t('activerecord.attributes.spree/product.less_than')} #{formatted_price(20_000)}",
        "#{formatted_price(20_000)} - #{formatted_price(50_000)}",
        "#{formatted_price(50_000)} - #{formatted_price(100_000)}"
      ]
    end

    def spree_homepage_banner_path
      SpreeStorefrontConfig.dig(current_store.code, :banner_image) || 'homepage/main_banner.jpg'
    rescue StandardError
      ''
    end

    def spree_homepage_banner_src_set
      SpreeStorefrontConfig.dig(current_store.code, :image_src_set) || 'homepage/main_banner'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_upper_path
      SpreeStorefrontConfig.dig(current_store.code, :category_banner_upper_image) || 'homepage/category_banner_upper.jpg'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_upper_src_set
      SpreeStorefrontConfig.dig(current_store.code, :category_upper_image_src_set) || 'homepage/category_banner_upper'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_left_path
      SpreeStorefrontConfig.dig(current_store.code, :promo_banner_left_image) || 'homepage/promo_banner_left.jpg'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_left_src_set
      SpreeStorefrontConfig.dig(current_store.code, :promo_left_image_src_set) || 'homepage/promo_banner_left'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_right_path
      SpreeStorefrontConfig.dig(current_store.code, :promo_banner_right_image) || 'homepage/promo_banner_right.jpg'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_right_src_set
      SpreeStorefrontConfig.dig(current_store.code, :promo_right_image_src_set) || 'homepage/promo_banner_right'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_lower_path
      SpreeStorefrontConfig.dig(current_store.code, :category_banner_lower_image) || 'homepage/category_banner_lower.jpg'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_lower_src_set
      SpreeStorefrontConfig.dig(current_store.code, :category_lower_image_src_set) || 'homepage/category_banner_lower'
    rescue StandardError
      ''
    end

    def spree_homepage_big_category_banner_path
      SpreeStorefrontConfig.dig(current_store.code, :big_category_banner_image) || 'homepage/big_category_banner.jpg'
    rescue StandardError
      ''
    end

    def spree_homepage_big_category_banner_src_set
      SpreeStorefrontConfig.dig(current_store.code, :big_category_image_src_set) || 'homepage/big_category_banner'
    rescue StandardError
      ''
    end

    def spree_homepage_banner_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_banner_url) || 'tecnologia/equipos/notebooks'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_upper_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_category_banner_upper_url) || 'tecnologia/partes-y-piezas/impresoras'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_lower_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_category_banner_lower_url) || 'tecnologia/equipos/all-in-one'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_left_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_promo_banner_left_url) || 'tecnologia/accesorios/mouse'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_right_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_promo_banner_right_url) || 'tecnologia/accesorios/teclados'
    rescue StandardError
      ''
    end

    def spree_homepage_big_category_banner_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_big_category_banner_url) || 'tecnologia/partes-y-piezas/monitores/monitores'
    rescue StandardError
      ''
    end

    def spree_homepage_read_more_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_read_more_url) || 'tecnologia/accesorios/bolsos-y-mochilas'
    rescue StandardError
      ''
    end

    def spree_fav_icon_url
      SpreeStorefrontConfig.dig(current_store.code, :spree_fav_icon_url) || 'favicon.ico'
    rescue StandardError
      ''
    end

    def spree_homepage_banner_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_banner_text) || 'Nuevos Productos'
    rescue StandardError
      ''
    end

    def spree_homepage_banner_url_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_banner_url_text) || 'VER MÁS'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_upper_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_category_banner_upper_text) || 'IMPRESION'
    rescue StandardError
      ''
    end

    def spree_homepage_category_banner_lower_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_category_banner_lower_text) || 'TODO EN UNO'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_left_small_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_promo_banner_left_small_text) || 'Proveedores'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_left_big_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_promo_banner_left_big_text) || '¿Deseas publicar aquí?'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_right_small_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_promo_banner_right_small_text) || 'Compradores'
    rescue StandardError
      ''
    end

    def spree_homepage_promo_banner_right_big_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_promo_banner_right_big_text) || 'Seguridad y Confianza'
    rescue StandardError
      ''
    end

    def spree_homepage_big_category_banner_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_big_category_banner_text) || 'Open-Box'
    rescue StandardError
      ''
    end

    def spree_homepage_fashion_trends_box_summer_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_fashion_trends_box_summer_text) || 'Nuevos Productos'
    rescue StandardError
      ''
    end

    def spree_homepage_fashion_trends_box_fashion_trends_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_fashion_trends_box_fashion_trends_text) || 'COMPRA RÁPIDO Y SIMPLE'
    rescue StandardError
      ''
    end

    def spree_homepage_fashion_trends_box_description_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_fashion_trends_box_description_text) || 'Nos enfocamos en una plataforma simple, rápida y amigable.'
    rescue StandardError
      ''
    end

    def spree_homepage_read_more_text
      SpreeStorefrontConfig.dig(current_store.code, :spree_homepage_read_more_text) || 'Leer más'
    rescue StandardError
      ''
    end

    def spree_homepage_taxon_url(slug)
      url = URI(slug)
      url.scheme.present? ? [slug, '_blank'] : [spree.nested_taxons_path(slug), '_self']
    end
  end
end
