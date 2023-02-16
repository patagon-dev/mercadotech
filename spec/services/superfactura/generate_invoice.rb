# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Superfactura::GenerateInvoice do
  let!(:vendor) { create(:vendor_with_superfactura) }
  let!(:order) { create(:order_ready_to_ship) }

  describe 'Superfactura Generate Invoice service' do
    context 'Create invoice with superfactura api' do
      before do
        order.bill_address.update_column(:purchase_order_number, '')
        order.reload
        @tipo_dte = '39'
      end

      it 'should generate invoice' do
        expect do
          @response = Superfactura::GenerateInvoice.new(order.id, vendor.id, @tipo_dte).run
        end.to change { Spree::Invoice.count }.by(1)

        expect(@response).to eq(1)
      end
    end
  end
end
