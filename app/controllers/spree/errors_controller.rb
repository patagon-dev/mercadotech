module Spree
  class ErrorsController < Spree::StoreController
    skip_before_action :verify_authenticity_token, only: [:not_found]

    def not_found
      respond_to do |format|
        format.html { render status: params[:code] }
        format.any  { head :not_found }
      end
    end
  end
end
