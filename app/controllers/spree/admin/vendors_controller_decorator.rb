module Spree
  module Admin
    module VendorsControllerDecorator
      def add_tags
        @vendor.tags.create(params[:tags].permit!)
        flash[:success] = Spree.t(:successfully_updated, resource: @vendor.name)
        render js: 'window.location.reload();'
      end

      def remove_tags
        @vendor.tags.find_by(id: params[:tag_id]).destroy if @vendor && params[:tag_id]
        flash[:success] = Spree.t(:successfully_updated, resource: @vendor.name)
        render js: 'window.location.reload();'
      end

      def add_vendor_term
        @vendor.vendor_terms.create(params[:vendor_term].permit!)
        flash[:success] = flash_message_for(@vendor, :successfully_updated)
        respond_with(@store) do |format|
          format.js { render js: 'window.location.reload();' }
        end
      end

      def remove_vendor_term
        @vendor.vendor_terms.find_by(id: params[:vendor_term_id]).destroy if @vendor && params[:vendor_term_id]
        flash[:success] = flash_message_for(@vendor, :successfully_updated)
        respond_with(@store) do |format|
          format.js { render js: 'window.location.reload();' }
        end
      end
    end
  end
end

::Spree::Admin::VendorsController.prepend Spree::Admin::VendorsControllerDecorator
