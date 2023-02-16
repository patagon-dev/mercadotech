module Spree
  module Admin
    module StoresControllerDecorator
    def self.prepended(base)
      base.before_action :load_payment_methods
      base.before_action :load_shipping_methods
    end

    def index
      @stores = Spree::Store.all
      @stores = @stores.ransack({ name_or_domains_or_code_cont: params[:q] }).result if params[:q]
      @stores = @stores.where(id: params[:ids].split(',')) if params[:ids]

      respond_with(@stores) do |format|
        format.html
        format.json
      end
    end

    protected

    def permitted_store_params
      params.require(:store).permit!
    end

    private
      def load_payment_methods
        @payment_methods = Spree::PaymentMethod.all
      end

      def load_shipping_methods
        @shipping_methods = Spree::ShippingMethod.all
      end
    end
  end
end

::Spree::Admin::StoresController.prepend Spree::Admin::StoresControllerDecorator
