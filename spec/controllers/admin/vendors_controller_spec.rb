# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::VendorsController, type: :controller do
  let!(:vendor) { create(:vendor) }
  let!(:admin_user) { create(:admin_user) }

  describe 'Vendor' do
    before(:each) do
      sign_in(admin_user)
    end

    context 'POST #add tags' do
      it 'should create vendor tags' do
        expect do
          post :add_tags, params: {
            tags: {
              'text' => 'free shipping',
              'color' => '#47a3e8'
            },
            'id' => vendor.slug
          }
        end.to change { Spree::VendorTag.count }.by(1)

        expect(response).to redirect_to(spree.add_tags_admin_vendor_path(vendor))
        expect(flash[:success]).to eq(Spree.t(:successfully_updated, resource: vendor.name))
      end
    end

    context 'DESTROY #remove tags' do
      let!(:vendor_tag) { create(:vendor_tag) }

      it 'should remove vendor tag' do
        expect do
          delete :remove_tags, params: {
            'tag_id' => vendor_tag.id,
            'id' => vendor.slug
          }
        end.to change { Spree::VendorTag.count }.by(-1)

        expect(response).to redirect_to(spree.remove_tags_admin_vendor_path(vendor))
        expect(flash[:success]).to eq(Spree.t(:successfully_updated, resource: vendor.name))
      end
    end
  end
end
