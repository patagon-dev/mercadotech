module Spree
  module Api
    class ReviewsController < Spree::Api::BaseController
      before_action :load_product, only: [:create]
      before_action :find_user, only: [:create]

      def create
        params[:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:rating].blank?

        @review = Spree::Review.new(review_attributes)
        @review.product = @product
        @review.ip_address = request.remote_ip
        @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
        authorize! :create, @review
        if @review.save
          respond_with(@review, status: 201, default_template: :show)
        else
          invalid_resource!(@review)
        end
      end

      private

      def review_attributes
        {
          rating: params[:rating],
          title: params[:title],
          review: params[:review],
          name: params[:name],
          show_identifier: params[:show_identifier],
          user_id: @user&.id,
          created_at: params[:review_date]
        }
      end

      def find_user
        @user = Spree::User.find_by(id: params[:user_id])
      end

      def load_product
        @product = Spree::Product.find_by(id: params[:product_id])
      end
    end
  end
end
