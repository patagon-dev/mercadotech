# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'
require 'sidekiq/testing'

RSpec.describe Spree::ReturnAuthorization do
  let(:return_item) do
    return_item = create(:return_item)
    return_item.return_authorization.update_columns(vendor_id: Spree::Product.last&.vendor_id)
    return_item.reload
  end
  let(:return_authorization) { return_item.return_authorization.reload }

  context 'associations' do
    it { should have_one(:shipment_label) }
    it { should belong_to(:vendor).optional }
  end

  context 'validations' do
    it { expect(return_authorization).to validate_presence_of(:stock_location) }
    it { expect(return_authorization).not_to validate_presence_of(:return_items) }
    it 'should validates presence of return items when user initiated' do
      return_authorization.user_initiated = true
      return_authorization.save
      expect(return_authorization).to validate_presence_of(:return_items)
    end
  end

  context 'callback #after_commit on_create' do
    before do
      ra = create(:return_authorization, return_items: [return_item], user_initiated: true)
      allow(ra).to receive(:create_return_delivery).and_return(true)
    end
    it 'should create return delivery label' do
      expect(ReturnDeliveryWorker).to have_enqueued_sidekiq_job(return_authorization.number)
    end
  end
end
