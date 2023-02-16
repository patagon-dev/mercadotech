# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Vendor do
  let(:vendor) { create(:vendor) }

  context 'validations' do
    it 'should return valid RUT response' do
      vendor.rut = '16607830-K'
      expect(vendor.valid?).to eq(true)

      vendor.rut = '10.268.889-9'
      expect(vendor.valid?).to eq(true)
    end

    it 'should return invalid RUT response' do
      vendor.rut = '16607830-S'

      expect(vendor.valid?).to eq(false)
      expect(vendor.errors.full_messages.join(',')).to eq("Rut #{Spree.t(:invalid_rut)}")
    end

    context 'if scrapinghub?' do
      let(:vendor) { create(:vendor_with_scrapinghub) }
      before { allow(vendor).to receive(:scrapinghub?).and_return(true) }
      it { expect(vendor).to validate_presence_of(:scrapinghub_api_key) }
      it { expect(vendor).to validate_presence_of(:scrapinghub_project_id) }
      it { expect(vendor).to validate_presence_of(:full_spider) }
      it { expect(vendor).to validate_presence_of(:quick_spider) }
    end

    context 'if superfactura_api?' do
      let(:vendor) { create(:vendor_with_superfactura) }
      before { allow(vendor).to receive(:superfactura_api?).and_return(true) }
      it { expect(vendor).to validate_presence_of(:superfactura_login) }
      it { expect(vendor).to validate_presence_of(:superfactura_password) }
      it { expect(vendor).to validate_presence_of(:superfactura_environment) }
    end

    context 'if enable_bank_transfer?' do
      let(:vendor) { create(:vendor_with_bank_transfer) }
      before { allow(vendor).to receive(:enable_bank_transfer?).and_return(true) }
      it { expect(vendor).to validate_presence_of(:bank_transfer_url) }
      it { expect(vendor).to validate_presence_of(:bank_transfer_login) }
      it { expect(vendor).to validate_presence_of(:bank_transfer_password) }
    end

    context 'if enable_moova?' do
      let(:vendor) { create(:vendor_with_moova) }
      before { allow(vendor).to receive(:enable_moova?).and_return(true) }
      it { expect(vendor).to validate_presence_of(:moova_api_key) }
      it { expect(vendor).to validate_presence_of(:moova_api_secret) }
    end

    context 'if set_minimum_order?' do
      let(:vendor) { create(:vendor, set_minimum_order: true, minimum_order_value: '2000') }
      before { allow(vendor).to receive(:set_minimum_order?).and_return(true) }
      it { expect(vendor).to validate_presence_of(:minimum_order_value) }
    end
  end

  context 'associations' do
    it { should have_many(:tags) }
    it { should have_and_belong_to_many(:enviame_carriers) }
  end

  context 'Vendor totals' do
    it 'should have correct #line_item_total, #shipment_total and #order_total' do
      2.times do
        product = create(:product, vendor_id: vendor.id, shipping_category: create(:shipping_category, vendor_id: vendor.id))
        product.master.stock_items.first.adjust_count_on_hand(10)
        create(:line_item, product: product)
      end
      order = create(:order_with_line_items, without_line_items: true, state: 'payment', line_items: Spree::LineItem.all)
      order.shipments.map(&:stock_location).each { |st| st.update_column(:vendor_id, vendor.id) }

      expect(vendor.line_item_total(order)).to eq(order.line_items.map(&:final_amount).sum.round)
      expect(vendor.shipment_total(order)).to eq(order.shipments.map(&:final_price).sum.round)
      expect(vendor.total_amount(order)).to eq(order.line_items.map(&:final_amount).sum.round + order.shipments.map(&:final_price).sum.round)
    end
  end
end
