module Spree
  module Admin
    module SlidesControllerDecorator
      private

      def slide_params
        params.require(:slide).permit(:name, :body, :link_url, :published, :image, :position, :product_id, :store_id)
      end
    end
  end
end

Spree::Admin::SlidesController.prepend Spree::Admin::SlidesControllerDecorator