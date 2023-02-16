# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'
require 'sidekiq/testing'

RSpec.describe Spree::Property do
  let(:product) { create(:product) }
  let(:property) { create(:property, vendor_id: product.vendor_id) }
  let!(:product_property) { create(:product_property, product: product, property: property) }

  context '#after_save callback' do
    it 'should reindex products when save change to filterable' do
      property.filterable = true
      property.save

      expect(IndexerWorker).to have_enqueued_sidekiq_job(:index, property.products.pluck(:id))
    end
  end
end
