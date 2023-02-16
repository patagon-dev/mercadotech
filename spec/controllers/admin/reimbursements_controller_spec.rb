# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::ReimbursementsController, type: :controller do
  let!(:reimbursement) { create(:reimbursement, reimbursement_status: 'reimbursed') }
  let!(:refund_history) { create(:refund_history, reference_number: reimbursement.number) }
  let!(:admin_user) { create(:admin_user) }

  describe 'Reimbursement' do
    before(:each) do
      sign_in(admin_user)
    end

    it 'should show refund histories' do
      get :show, params: {
        id: reimbursement.id,
        order_id: reimbursement.order.number
      }

      expect(response).to have_http_status(200)
      expect(assigns(:refund_history)).to be_an_instance_of(Spree::RefundHistory)
    end
  end
end
