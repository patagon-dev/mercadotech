module Spree
  module Api
    module RelationsControllerDecorator
      def self.prepended(base)
        base.before_action :load_data, only: %i[create update]
        base.before_action :find_relation, only: [:destroy]
      end

      def create
        authorize! :create, Spree::Relation
        related_item_ids = params[:relation][:related_to_id] - @product.relations.map { |rp| rp.related_to_id.to_s }
        unless related_item_ids.any?
          not_found
          return
        end

        response = []
        related_item_ids.each_with_index do |id, idx|
          @relation = @product.relations.new(discount_amount: relation_params[:discount_amount],
                                             relation_type_id: relation_params[:relation_type_id],
                                             related_to_type: 'Spree::' << relation_params[:related_to_type],
                                             related_to_id: id)
          response[idx] = @relation.save
        end
        response.include?(true) ? respond_with(@product.relations, status: 201, default_template: 'show.v1') : invalid_resource!(@relation)
      end

      def update
        authorize! :update, Spree::Relation
        related_item_ids = params[:relation][:related_to_id]
        unless related_item_ids.any?
          not_found
          return
        end
        ids = @product.relations.ids

        response = []
        related_item_ids.each_with_index do |id, idx|
          @relation = @product.relations.new(discount_amount: relation_params[:discount_amount],
                                             relation_type_id: relation_params[:relation_type_id],
                                             related_to_type: 'Spree::' << relation_params[:related_to_type],
                                             related_to_id: id)
          response[idx] = @relation.save
        end

        if response.include?(true)
          @product.relations.where(id: ids).destroy_all # destroy old relations
          respond_with(@product.relations, status: 201, default_template: 'show.v1')
        else
          invalid_resource!(@relation)
        end
      end

      def destroy
        authorize! :destroy, Spree::Relation
        @relations.destroy_all if @relations.any?
      end

      private

      def find_relation
        @relations = Spree::Relation.where(related_to_id: params[:relation][:id], relatable_id: params[:product_id])
      end

      def load_data
        @product = Spree::Product.find_by(id: params[:product_id])
      end
    end
  end
end

::Spree::Api::RelationsController.prepend Spree::Api::RelationsControllerDecorator
