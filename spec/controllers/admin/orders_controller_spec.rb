# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::OrdersController, type: :controller do
  let!(:admin_user) { create(:admin_user) }
  let!(:order) { create(:order_ready_to_ship) }
  let!(:enviame_carrier) { create(:enviame_carrier) }
  let!(:enviame_carrier_service) { create(:enviame_carrier_service, enviame_carrier: enviame_carrier) }

  describe 'Order' do
    before(:each) do
      sign_in(admin_user)
    end

    context '#GET' do
      it 'should get enviame carrier services' do
        shipment = order.shipments.first
        valid_data = { 'data' => [[enviame_carrier_service.id, enviame_carrier_service.name]], 'shipment_number' => shipment.number }

        get :get_services, params: {
          carrier_id: enviame_carrier.id,
          shipment_number: shipment.number
        }

        expect(json_response).to eq valid_data
      end

      it 'should generate pickup list for bulk orders' do
        order2 = create(:order_ready_to_ship)

        get :generate_pickup_list, params: {
          pickup_list: {
            order_ids: "#{order.id},#{order2.id}"
          }
        }

        expect(response.headers['Content-Type']).to eq('application/pdf')
      end

      it 'should generate purchase list for bulk orders' do
        order2 = create(:order_ready_to_ship)

        get :generate_purchase_list, params: {
          purchase_list: {
            order_ids: "#{order.id},#{order2.id}"
          }
        }

        expect(response.headers['Content-Type']).to eq('application/pdf')
      end
    end

    context '#DELETE' do
      it 'should remove shipment label' do
        shipment = order.shipments.first
        shipment_label = create(:shipment_label, shipment_id: shipment.id)

        expect do
          delete :remove_shipping_label, params: {
            shipment_label_id: shipment_label.id
          }
        end.to change { Spree::ShipmentLabel.count }.by(-1)

        expect(json_response).to eq({ 'success' => true, 'message' => 'Successfully Removed!' })
      end
    end

    # context '#POST' do
    #   it 'should create shipment label for enviame service' do
    #     shipment = order.shipments.first

    #     expect do
    #       post :create_shipment_delivery, params: {
    #         shipment_number: shipment.number,
    #         carrier_id: enviame_carrier.id,
    #         service_id: enviame_carrier_service.id,
    #         n_packages: '1'
    #       }
    #     end.to change { Spree::ShipmentLabel.count }.by(1)

    #     expect(json_response).to eq({ 'success' => true, 'message' => 'Delivery created!' })
    #   end

    #   # getting error for place is not in budget in API
    #   it 'should create shipment label for moova service' do
    #     shipment = order.shipments.first
    #     vendor2 = create(:vendor_with_moova, name: 'moova vendor')
    #     shipment.stock_location.update(vendor_id: vendor2.id)
    #     shipment.reload

    #     expect do
    #       post :create_shipment_delivery, params: {
    #         shipment_number: shipment.number,
    #         carrier_id: 'moova'
    #       }
    #     end.to change { Spree::ShipmentLabel.count }.by(1)

    #     expect(json_response).to eq({ 'success' => true, 'message' => 'Delivery created!' })
    #   end
    # end

    context '#PUT' do
      it 'should mark payment state refunded' do
        payment = create(:payment, state: 'refund_pending', order: order)

        put :mark_payment_refunded, params: {
          number: payment.number
        }

        expect(flash[:success]).to eq(Spree.t(:successfully_updated, resource: 'Pago'))
      end
    end
  end
end
