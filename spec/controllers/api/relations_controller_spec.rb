# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'
require 'rspec/active_model/mocks'

RSpec.describe Spree::Api::RelationsController, type: :controller do
  let!(:relation_type) { create(:relation_type) }
  let!(:product1) { create(:product) }
  let!(:product2) { create(:product) }
  let!(:relation) { create(:relation, relatable: product2, related_to: product1, relation_type: relation_type) }

  describe 'RelationsAPIContoller' do
    before do
      current_api_user.generate_spree_api_key!
      current_api_user.spree_roles << create(:role, name: 'admin')
      stub_authentication!
    end

    context 'POST#create' do
      it 'should create relations of product' do
        expect do
          post :create, params: {
            relation: {
              related_to_type: 'Product',
              related_to_id: [product2.id.to_s],
              relation_type_id: relation_type.id,
              discount_amount: '0.0'
            },
            product_id: product1.id,
            token: current_api_user.spree_api_key,
            format: 'json'
          }
        end.to change { Spree::Relation.count }.by(1)

        expect(response).to have_http_status(201)
        expect(response).to render_template(:show)
      end
    end

    context 'DELETE#destroy' do
      it 'should destroy relations of product' do
        expect do
          delete :destroy, params: {
            product_id: product2.id,
            id: [product1.id.to_s],
            relation: {
              id: [product1.id.to_s]
            },
            token: current_api_user.spree_api_key,
            format: 'json'
          }
        end.to change { Spree::Relation.count }.by(-1)

        expect(response).to have_http_status(204)
      end
    end

    context 'PUT#update' do
      it 'should update relations of product' do
        product3 = create(:product)

        put :update, params: {
          relation: {
            related_to_type: 'Product',
            related_to_id: [product3.id.to_s],
            relation_type_id: relation_type.id,
            discount_amount: '0.0'
          },
          product_id: product1.id,
          id: product3.id,
          token: current_api_user.spree_api_key,
          format: 'json'
        }

        expect(response).to have_http_status(201)
        expect(response).to render_template(:show)
      end
    end
  end
end
