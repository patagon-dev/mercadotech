module Spree
  module Api
    module V1
      module TaxonsControllerDecorator
        def index
          @taxons = if taxonomy
                      taxonomy.root.children
                    elsif params[:ids]
                      Spree::Taxon.includes(:children).accessible_by(current_ability).where(id: params[:ids].split(','))
                    else
                      Spree::Taxon.includes(:children).accessible_by(current_ability).order(:taxonomy_id, :lft)
                    end
          @taxons = @taxons.by_store(current_store) if current_store.present? # Added for store specific taxons
          @taxons = @taxons.ransack(params[:q]).result
          @taxons = @taxons.page(params[:page]).per(params[:per_page])
          respond_with(@taxons)
        end
      end
    end
  end
end

::Spree::Api::V1::TaxonsController.prepend Spree::Api::V1::TaxonsControllerDecorator