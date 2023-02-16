# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Invoice do
  let(:invoice) { create(:invoice_with_superfactura_document) }

  context 'validations' do
    it 'should validates presence of order and vendor' do
      expect(invoice).to validate_presence_of(:order_id)
      expect(invoice).to validate_presence_of(:vendor_id)
    end

    it 'should validates document content type' do
      expect(invoice.document.blob.content_type).to eq('application/pdf')
    end

    it 'should validate document with document type' do
      invoice.document.attach(io: File.open(Rails.root.join('spec/fixtures/attachments', 'invoices', 'test.png')), filename: 'test.png', content_type: 'image/png')
      expect(invoice.errors.full_messages.join(',')).to eq('Wrong document format')
    end
  end

  context 'associations' do
    it 'should belongs_to order and vendor' do
      expect(invoice).to belong_to(:order)
      expect(invoice).to belong_to(:vendor)
    end

    it 'should have one attachment' do
      expect(invoice.document).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  context 'callback' do
    context '#after_commit on create' do
      it 'should set filename of attachment' do
        invoice = create(:invoice_with_manual_upload)
        file_type = invoice.document.blob.content_type.split('/')[1]
        expect(invoice.document.blob.filename.to_s).to eq("#{invoice.tipo_dte}_#{invoice.number}.#{file_type}")
      end
    end
  end
end
