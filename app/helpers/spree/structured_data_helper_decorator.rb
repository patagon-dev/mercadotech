module Spree
  module StructuredDataHelperDecorator
    private

    def structured_product_hash(product)
      Rails.cache.fetch(common_product_cache_keys + ["spree/structured-data/#{product.cache_key_with_version}"]) do
        json_ld = {
          '@context': 'https://schema.org/',
          '@type': 'Product',
          '@id': product.formatted_sku,
          url: spree.product_url(product),
          name: build_meta_title(product),
          image: structured_images(product),
          description: build_meta_discription(product.name),
          sku: structured_sku(product),
          mpn: product.partnumber,
          brand: {
            '@type': 'Brand',
            name: product.manufacturer
          },
          offers: {
            '@type': 'Offer',
            price: product.default_variant.price_in(current_currency).amount,
            priceCurrency: current_currency,
            availability: check_product_availability(product),
            url: spree.product_url(product),
            itemCondition: 'https://schema.org/NewCondition',
            priceValidUntil: Date.tomorrow,
            availabilityEnds: product.discontinue_on ? product.discontinue_on.strftime('%F') : ''
          }
        }

        product.reviews_count == 0 ? json_ld : json_ld.merge(review_structured_data(product))
      end
    end

    def review_structured_data(product)
      {
        review: product_reviews(product),
        aggregateRating: {
          '@type': 'AggregateRating',
          ratingValue: product.avg_rating.to_f,
          reviewCount: product.reviews_count
        }
      }
    end

    def product_reviews(product)
      product.reviews.last(2).map do |review|
        {
          '@type': 'Review',
          name: review.title,
          datePublished: review.created_at,
          reviewBody: review.review,
          reviewRating: {
            '@type': 'Rating',
            name: review.title,
            ratingValue: review.rating
          },
          author: {
            '@type': 'Person',
            name: review.name? ? review.name : Spree.t(:guest_user)
          }
        }
      end
    end

    def build_meta_title(product)
      if product.name? && product.partnumber? && product.vendor_id?
        "#{[product.name.split(' - ').first, product.partnumber].compact.join(' | ')} #{product.vendor.name}"
      else
        product.name.split(' - ').first.to_s
      end
    end

    def check_product_availability(product)
      availability = product.in_stock? ? 'InStock' : 'OutOfStock'
      "https://schema.org/#{availability}"
    end

    def structured_images(product)
      image = default_image_for_product_or_variant(product)

      return '' unless image

      s3_persisted_url(image.attachment)
    end
  end
end

::Spree::StructuredDataHelper.prepend Spree::StructuredDataHelperDecorator
