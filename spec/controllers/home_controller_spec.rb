# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::HomeController, type: :controller do
  let(:user) { create(:user, email: 'dcecewc@sxw.com') }
  let!(:store) { create(:store) }
  let!(:list) { create(:list, store_id: store.id, key: 'WKmiW892Os7638OVDqp17j3HTg') }

  # describe 'Home' do
  #   before(:each) do
  #     sign_in(user)
  #   end

  #   context '#GET subscribe' do
  #     it 'should get subscribe response of user in list' do
  #       get :subscription, params: {
  #         list_key: list.key,
  #         email: user.email
  #       }

  #       expect(flash[:success]).to eq(Spree.t(:successfully_subscribed, scope: :list))
  #       expect(response).to redirect_to(spree.account_path)
  #     end
  #   end

  #   context '#GET unsubscribe' do
  #     it 'should get unsubscribe response of user in list' do
  #       get :unsubscription, params: {
  #         list_key: list.key,
  #         email: user.email
  #       }

  #       expect(flash[:success]).to eq(Spree.t(:successfully_unsubscribed, scope: :list))
  #       expect(response).to redirect_to(spree.account_path)
  #     end
  #   end

  #   context '#GET subcription status' do
  #     it 'should get the subcription status unconfirmed in list' do
  #       get :subcription_status, params: {
  #         id: list.id,
  #         format: 'json'
  #       }

  #       expect(JSON.parse(response.body)).to eq(['Unconfirmed', list.id.to_s])
  #     end
  #   end
  # end
end
