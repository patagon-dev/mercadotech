module Spree
  module BaseHelperDecorator
    def og_meta_data
      og_meta = {}

      if object.is_a? Spree::Product
        image                             = default_image_for_product_or_variant(object)
        og_meta['og:image']               = s3_persisted_url(image.attachment) if image&.attachment

        og_meta['og:url']                 = spree.url_for(object) if frontend_available? # url_for product needed
        og_meta['og:type']                = object.class.name.demodulize.downcase
        og_meta['og:title']               = build_meta_title(object)
        og_meta['og:description']         = build_meta_discription(object.name)

        price = object.price_in(current_currency)
        if price
          og_meta['product:price:amount']   = price.amount
          og_meta['product:price:currency'] = current_currency
        end
      end

      og_meta
    end

    def meta_data
      meta = {}

      if object.is_a? ApplicationRecord
        meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
        meta[:description] = object.meta_description if object[:meta_description].present?
      end

      if object.is_a?(Spree::Product)
        meta[:keywords] = object.meta_keywords
        meta[:description] = build_meta_discription(object.name)
      end

      if meta[:keywords].blank? || meta[:description].blank?
        if object && object[:name].present?
          meta.reverse_merge!(keywords: [object.name, current_store.meta_keywords].reject(&:blank?).join(', '),
                              description: [object.name, current_store.meta_description].reject(&:blank?).join(', '))
        else
          meta.reverse_merge!(keywords: (current_store.meta_keywords || current_store.seo_title),
                              description: (current_store.meta_description || current_store.seo_title))
        end
      end
      meta
    end

    def build_meta_title(product)
      if product.name? && product.partnumber? && product.vendor_id?
        "#{[product.name.split(' - ').first, product.partnumber].compact.join(' | ')} #{product.vendor.name}"
      else
        "#{product.name.split(' - ').first}"
      end
    end

    def build_meta_discription(product_name)
      Spree.t(:product_meta_description, product: product_name, store: current_store&.name)
    end
  end
end

::Spree::BaseHelper.prepend Spree::BaseHelperDecorator
