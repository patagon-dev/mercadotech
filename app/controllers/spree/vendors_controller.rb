module Spree
  class VendorsController < Spree::StoreController
    def show
      @vendor = Vendor.with_deleted.friendly.find(params[:id])
    end
  end
end
