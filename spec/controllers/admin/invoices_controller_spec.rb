# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::InvoicesController, type: :controller do
  let!(:vendor) { create(:vendor_with_superfactura) }
  let!(:vendor_user) { create(:user, spree_roles: [create(:role, name: 'vendor')], vendors: [vendor]) }
  let!(:admin_user) { create(:admin_user) }
  let!(:order) { create(:order_ready_to_ship) }
  let!(:invoice) { create(:invoice_with_superfactura_document, order: order, vendor: vendor) }

  describe 'Invoices' do
    before(:each) do
      user = [admin_user, vendor_user].sample
      sign_in(user)
    end

    context 'GET #index' do
      it 'should load invoices and vendors' do
        get :index, params: {
          order_id: order.number,
          vendor_id: vendor.id
        }

        expect(response).to have_http_status(:success)
        expect(assigns(:invoices)).to eq(order.invoices)
      end
    end

    describe 'POST #create' do
      context 'Generate Invoice' do
        it 'should create invoice with manual upload' do
          document = fixture_file_upload(Rails.root.join('spec/fixtures/attachments/invoices', '1234.pdf'), 'application/pdf')

          expect do
            post :create, params: {
              order_id: order.number,
              vendor_id: vendor.id,
              invoice_type: '39',
              invoice: {
                number: '1234',
                document: document
              }
            }
          end.to change { Spree::Invoice.count }.by(1)

          expect(response).to redirect_to(spree.admin_order_invoices_path(order.number))
        end

        # it 'should create invoice with superfactura api' do
        #   order.bill_address.update_column(:purchase_order_number, '')
        #   order.reload

        #   expect do
        #     post :create, params: {
        #       order_id: order.number,
        #       vendor_id: vendor.id,
        #       invoice_type: '39'
        #     }
        #   end.to change { Spree::Invoice.count }.by(1)

        #   expect(response).to redirect_to(spree.admin_order_invoices_path(order.number))
        # end
      end
    end
  end
end
