module Spree
  module Admin
    class VendorSettingsController < Spree::Admin::BaseController
      before_action :authorize
      before_action :load_vendor

      def update
        @vendor.create_image(attachment: vendor_params[:image]) if vendor_params[:image] && Spree.version.to_f >= 3.6
        if @vendor.update(vendor_params.except(:image))
          flash[:success] = Spree.t(:successfully_updated, resource: @vendor.name)
        else
          flash[:error] = @vendor.errors.full_messages.join(',')
        end
        redirect_back(fallback_location: spree.admin_vendor_settings_path)
      end

      def add_tag
        @vendor.tags.create(params[:tags].permit!)
        flash[:success] = Spree.t(:successfully_updated, resource: @vendor.name)
        render js: 'window.location.reload();'
      end

      def remove_tag
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

      def manage_spider
        response = SpiderManager::ManageLogs.new(@vendor&.id, params['spider_name']).perform
        @spider_logs = Spree::SpiderManagement.where(spider_name: params['spider_name'], vendor_id: @vendor&.id)

        flash[response[:status]] = response[:message]
      end

      def schedule_spider
        response = SpiderManager::RunJob.new(@vendor&.id, params['spider_name']).perform
        flash[response[:status]] = response[:message]
        redirect_back(fallback_location: spree.admin_vendor_settings_path)
      end

      def scraped_item_list
        response = SpiderManager::Items.new(@vendor&.id, params['job_id']).perform
        flash[response[:status]] = response[:message]
        redirect_back(fallback_location: spree.admin_vendor_settings_path)
      end

      private

      def authorize
        authorize! :manage, :vendor_settings
      end

      def load_vendor
        @vendor = current_spree_vendor
        raise ActiveRecord::RecordNotFound unless @vendor
      end

      def vendor_params
        params.require(:vendor).permit(Spree::PermittedAttributes.vendor_attributes)
      end
    end
  end
end
