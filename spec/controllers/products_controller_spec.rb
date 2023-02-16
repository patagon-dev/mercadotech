# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::ProductsController, type: :controller do
  let!(:product) { create(:product) }
  let!(:other1)  { create(:product) }

  context 'Related Products' do
    before do
      @relation_name = %w[accessories similar identical].sample
      relation_type = create(:relation_type, name: "#{@relation_name.capitalize} Products")
      relation = create(:relation, relatable: product, related_to: other1, relation_type: relation_type, position: 0)
    end
    it 'should load related products if present' do
      get :related_products, params: {
        id: product.slug,
        relation_type: @relation_name
      }

      expect(response).to have_http_status('200')
      expect(response).to render_template("spree/products/#{@relation_name}")
    end

    it 'should not load related products if product has not' do
      get :related_products, params: {
        id: create(:product).slug,
        relation_type: @relation_name
      }

      expect(response).to have_http_status('200')
      expect(response.body).to be_empty
    end
  end
end
