# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'
require 'sidekiq/testing'

RSpec.describe Spree::Admin::ProductsController, type: :controller do
  let!(:vendor) { create(:vendor) }
  let!(:admin_user) { create(:admin_user) }

  describe 'Product' do
    before(:each) do
      sign_in(admin_user)
    end

    context '#GET' do
      it 'should add job of import csv products to sidekiq' do
        expect do
          get :import_csv_products, params: {
            method_name: 'from_csv',
            vendor_id: vendor.id
          }
        end.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1)

        expect(flash[:success]).to eq(Spree.t(:products_are_importing_and_take_time))
      end
    end

    context '#PATCH' do
      it 'should bulk update categories to products' do
        product1 = create(:product)
        product2 = create(:product)
        taxon1 = create(:taxon)
        taxon2 = create(:taxon)

        patch :update_products_categories, params: {
          taxon_ids: [ taxon1.id, taxon2.id ],
          add_data: 'false',
          product_ids: "#{product1.id},#{product2.id}"
        }

        expect(flash[response[:status]]).to eq(response[:message])
        expect(product1.taxons.count).to eq(2)
        expect(product2.taxons.count).to eq(2)
      end
    end
  end
end
