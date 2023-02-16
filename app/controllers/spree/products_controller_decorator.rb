module Spree
  module ProductsControllerDecorator
    include RedundantProduct
    def self.prepended(base)
      base.helper Spree::ReviewsHelper
      base.before_action :load_product, only: %i[show related related_products competitor_prices]
      base.before_action :comment_tool_sign_up, only: :show
    end

    def index
      super
      duplicate_product_ids
    end

    def show
      super
      self.title = build_meta_title(@product)
      @product_properties = @product_properties.where("value IS NOT NULL AND value != ''") if @product_properties.present?
      @product_vendor = @product.vendor
      @datasheet_files = @product.datasheet_files.attachments
    end

    def related_products
      relation = params[:relation_type]

      case relation
      when 'similar'
        @similar_products = @product.similar_products
      when 'accessories'
        @accessories_products = @product.accessories_products
      when 'identical'
        @identical_products = @product.identical_products
      else
        head :no_content
      end
      render template: "spree/products/#{relation}", layout: false
    end

    def competitor_prices
      if @product.competitor_prices_ability(current_store.code)
        unless Rails.env.development?
          cached_api_response = Rails.cache.send(:read_entry,
                                                 "product/#{@product.solotodo_id}/competitor_prices-#{Date.today.to_s(:number)}")
          unless cached_api_response.present?
            cached_api_response = find_competitor_prices(@product.solotodo_id)
            Rails.cache.send(:write_entry,
                             "product/#{@product.solotodo_id}/competitor_prices-#{Date.today.to_s(:number)}", cached_api_response)
          end
        else
          # for development environments
          cached_api_response = find_competitor_prices(@product.solotodo_id)
        end

        if cached_api_response.present?
          @competitors_data = cached_api_response['competitors_prices']
          @discount_label = ((1 - (cached_api_response['average_price'] / @product.price)) * 100).round
        end

        render template: 'spree/products/competitor_prices', layout: false
      else
        head :no_content
      end
    end

    private

    def find_competitor_prices(solotodo_id)
      CompetitorPrice::Api.new(solotodo_id).execute
    end

    def comment_tool_sign_up
      if current_spree_user.present?
        unless current_spree_user.comment_tool_signup && comment_tool_loggedin?
          signup_response = CommentTool::SignupApi.new(current_spree_user.email, current_spree_user.nombres).execute
          if signup_response
            current_spree_user.update(comment_tool_signup: signup_response)
          end

          login_response = CommentTool::LoginApi.new(current_spree_user.email).execute
          if login_response
            cookies['commentoCommenterToken'] = login_response
          end
        end
      end
    end

    def comment_tool_loggedin?
      cookies['commentoCommenterToken'].present?
    end

    def build_meta_title(product)
      if product.name? && product.partnumber? && product.vendor_id?
        "#{[product.name.split(' - ').first, product.partnumber].compact.join(' | ')} #{product.vendor.name}"
      else
        product.name.split(' - ').first.to_s
      end
    end
  end
end

::Spree::ProductsController.prepend Spree::ProductsControllerDecorator
