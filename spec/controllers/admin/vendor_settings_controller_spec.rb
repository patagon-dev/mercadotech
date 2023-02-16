# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::VendorSettingsController, type: :controller do
  let!(:vendor) { create(:vendor) }
  let!(:vendor_user) { create(:user, spree_roles: [create(:role, name: 'vendor')], vendors: [vendor]) }

  describe 'Vendor' do
    before(:each) do
      sign_in(vendor_user)
    end

    context 'POST #add tags' do
      it 'should create vendor tags' do
        expect do
          post :add_tag, params: {
            tags: {
              'text' => 'free shipping',
              'color' => '#47a3e8'
            },
            'id' => vendor.slug
          }
        end.to change { Spree::VendorTag.count }.by(1)

        expect(response).to redirect_to(spree.admin_vendor_settings_tags_path)
        expect(flash[:success]).to eq(Spree.t(:successfully_updated, resource: vendor.name))
      end
    end

    context 'DESTROY #remove tags' do
      let!(:vendor_tag) { create(:vendor_tag) }

      it 'should remove vendor tag' do
        expect do
          delete :remove_tag, params: {
            'tag_id' => vendor_tag.id,
            'id' => vendor.slug
          }
        end.to change { Spree::VendorTag.count }.by(-1)

        expect(response).to redirect_to(spree.admin_vendor_settings_tags_delete_path)
        expect(flash[:success]).to eq(Spree.t(:successfully_updated, resource: vendor.name))
      end
    end

    context 'UPDATE #vendor settings' do
      it 'should update vendor image' do
        logo_image = fixture_file_upload(Rails.root.join('spec/fixtures/attachments/logo', 'test_email_logo.png'), 'image/png')
        patch :update, params: {
          vendor: {
            'image' => logo_image
          }
        }

        expect(response).to redirect_to(spree.admin_vendor_settings_path)
        expect(flash[:success]).to eq(Spree.t(:successfully_updated, resource: vendor.name))
      end
    end
  end
end
