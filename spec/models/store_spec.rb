# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Store do
  let!(:store) { create(:store) }
  let!(:store_authentication_type) { create(:store_authentication_type, store: store) }
  let!(:list) { create(:list, store: store) }

  context 'associations' do
    it { should have_many(:store_authentication_types) }
    it { should have_many(:authentication_types).through(:store_authentication_types) }
    it { should have_many(:lists) }

    it 'should have one attachment' do
      expect(store.mailer_logo).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  context 'validations' do
    it { expect(store).to validate_presence_of(:invoice_types) }

    it 'should validates logo image content type image' do
      expect(store.mailer_logo.attachment.blob.content_type).to eq('image/png')
    end

    it 'should not validate email logo with wrong content type' do
      store.mailer_logo.attach(io: File.open(Rails.root.join('spec/fixtures/attachments', 'invoices', '1234.pdf')), filename: '1234.pdf', content_type: 'application/pdf')
      expect(store.errors.full_messages.join(',')).to eq(Spree.t(:mailer_logo_message))
    end
  end

  describe 'callbacks' do
    context '#after_save' do
      let!(:vendor) { create(:vendor, state: 'active') }
      let!(:product) { create(:base_product, vendor_id: vendor.id, shipping_category: create(:shipping_category, vendor_id: vendor.id), stores: [store]) }

      it 'should clear product cache' do
        last_updated_at = product.updated_at - 2.days
        store.comment_tool = 'test script'
        store.save

        expect(product.updated_at).not_to eq(last_updated_at)
      end
    end
  end
end
