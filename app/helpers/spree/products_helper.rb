module Spree
  module ProductsHelper
    include BaseHelper

    # returns the formatted price for the specified variant as a full price or a difference depending on configuration
    def variant_price(variant)
      if Spree::Config[:show_variant_full_price]
        variant_full_price(variant)
      else
        variant_price_diff(variant)
      end
    end

    # returns the formatted price for the specified variant as a difference from product price
    def variant_price_diff(variant)
      variant_amount = variant.amount_in(current_currency)
      product_amount = variant.product.amount_in(current_currency)
      return if variant_amount == product_amount || product_amount.nil?

      diff   = variant.amount_in(current_currency) - product_amount
      amount = Spree::Money.new(diff.abs, currency: current_currency).to_html
      label  = diff > 0 ? :add : :subtract
      "(#{Spree.t(label)}: #{amount})".html_safe
    end

    # returns the formatted full price for the variant, if at least one variant price differs from product price
    def variant_full_price(variant)
      product = variant.product
      unless product.variants.active(current_currency).all? { |v| v.price == product.price }
        Spree::Money.new(variant.price, currency: current_currency).to_html
      end
    end

    def default_variant(variants, product)
      variants_option_types_presenter(variants, product).default_variant || product.default_variant
    end

    def should_display_compare_at_price?(default_variant)
      default_variant_price = default_variant.price_in(current_currency)
      default_variant_price.compare_at_amount.present? && (default_variant_price.compare_at_amount > default_variant_price.amount)
    end

    def used_variants_options(variants, product)
      variants_option_types_presenter(variants, product).options
    end

    # converts line breaks in product description into <p> tags (for html display purposes)
    def product_description(product)
      product.description.blank? ? Spree.t(:product_has_no_description) : product.description
    end

    def line_item_description_text(description_text)
      if description_text.present?
        truncate(strip_tags(description_text.gsub('&nbsp;', ' ').squish), length: 100)
      else
        Spree.t(:product_has_no_description)
      end
    end

    #override for searchkick products cache key
    def cache_key_for_products(products = @products, additional_cache_key = nil)
      count = products.count
      hash = Digest::SHA1.hexdigest(params.to_json)
      max_updated_at = products.map(&:updated_at).max || Date.today
      "#{I18n.locale}/#{current_currency}/spree/products/all-#{params[:page]}-#{hash}-#{count}-#{max_updated_at.to_s(:number)}"
    end

    def product_show_images_cache_key(images)
      max_updated_at = (images.map(&:updated_at).max || Date.today).to_s(:number)
      "spree/products/images/#{images.map(&:id).join('-')}-#{max_updated_at}"
    end

    def product_image_cache_key(image)
      recent_updated_at = (image&.updated_at || Date.today).to_s(:number)
      "spree/products/images/#{image&.id}-#{recent_updated_at}"
    end

    def filter_cache_key(data, filter_type)
      product_filter_type = filter_type

      case product_filter_type
      when 'filterable_properties' || 'available_option_types'
        "#{data.values.map { |pp| pp.pluck(:updated_at).max }.max}"
      when 'vendor_filters'
        "#{data.join()}"
      when 'brand_filters'
        "#{data.join().remove('-').gsub(/[\s,]/ ,"")}"
      when 'price_filters'
        "#{data.values.join().gsub(/[\s,]/ ,"")}"
      else
        "#{Date.today.to_s(:number)}"
      end
    end

    def cache_key_for_product(product = @product)
      cache_key_elements = common_product_cache_keys
      cache_key_elements += [
        product.cache_key_with_version,
        product.possible_promotions.map(&:cache_key)
      ]

      cache_key_elements.compact.join('/')
    end

    def limit_descritpion(string)
      return string if string.length <= 450

      string.slice(0..449) + '...'
    end

    # will return a human readable string
    def available_status(product)
      return Spree.t(:discontinued) if product.discontinued?
      return Spree.t(:deleted) if product.deleted?

      if product.available?
        Spree.t(:available)
      elsif product.available_on&.future?
        Spree.t(:pending_sale)
      else
        Spree.t(:no_available_date_set)
      end
    end

    def product_images(product, variants)
      if product.variants_and_option_values(current_currency).any?
        variants_without_master_images = variants.reject(&:is_master).map(&:images).flatten

        if variants_without_master_images.any?
          return variants_without_master_images
        end
      end

      variants.map(&:images).flatten
    end

    def product_variants_matrix(is_product_available_in_currency)
      Spree::VariantPresenter.new(
        variants: @variants,
        is_product_available_in_currency: is_product_available_in_currency,
        current_currency: current_currency,
        current_price_options: current_price_options,
        current_store: current_store
      ).call.to_json
    end

    def product_relation_types
      @product_relation_types ||= @product.respond_to?(:relation_types) ? @product.relation_types : []
    end

    def product_relations_by_type(relation_type)
      return [] if product_relation_types.none? || !@product.respond_to?(:relations)

      product_ids = @product.relations.where(relation_type: relation_type).pluck(:related_to_id).uniq

      return [] if product_ids.empty?

      Spree::Product.
        available.not_discontinued.distinct.
        where(id: product_ids).
        includes(
          :tax_category,
          master: [
            :prices,
            { images: { attachment_attachment: :blob } },
          ]
        ).
        limit(Spree::Config[:products_per_page])
    end

    def related_products
      ActiveSupport::Deprecation.warn(<<-DEPRECATION, caller)
        ProductsHelper#related_products is deprecated and will be removed in Spree 5.0.
        Please use ProductsHelper#relations from now on.
      DEPRECATION

      return [] unless @product.respond_to?(:has_related_products?)

      @related_products ||= relations_by_type('related_products')
    end

    def product_available_in_currency?
      !(@product_price.nil? || @product_price.zero?)
    end

    def common_product_cache_keys
      base_cache_key + price_options_cache_key
    end

    private

    def price_options_cache_key
      current_price_options.sort.map(&:last).map do |value|
        value.try(:cache_key) || value
      end
    end

    def variants_option_types_presenter(variants, product)
      @variants_option_types_presenter ||= begin
        option_types = Spree::Variants::OptionTypesFinder.new(variant_ids: variants.map(&:id)).execute

        Spree::Variants::OptionTypesPresenter.new(option_types, variants, product)
      end
    end

    def product_with_minimum_price?(current_product)
      @duplicate_product_ids.include?(current_product.id)
    end

    def cache_product_properties
      cache_properties = [@product_properties.pluck(:updated_at).max.to_s(:number), @product.slug]
    end
  end
end
