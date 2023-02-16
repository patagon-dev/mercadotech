# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::ListsController, type: :controller do
  let!(:admin_user) { create(:admin_user) }
  let!(:store) { create(:store) }
  let!(:list) { create(:list, store_id: store.id, key: 'WKmiW892Os7638OVDqp17j3HTg') }

  describe 'Lists' do
    before(:each) do
      sign_in(admin_user)
    end

    context 'GET #index' do
      it 'should load newsletter lists' do
        get :index

        expect(response).to have_http_status(:success)
        expect(assigns(:lists)).to match_array(list)
      end
    end

    context 'GET #new' do
      it 'should create newsletter list instance' do
        get :new

        expect(response).to have_http_status(:success)
        expect(assigns(:list)).to be_a_new(Spree::List)
      end
    end

    context 'POST #create' do
      it 'should create newsletter list' do
        expect do
          post :create, params: {
            list: {
              store_id: store.id,
              key: '1',
              name: 'testing',
              default_list: '1'
            }
          }
        end.to change { Spree::List.count }.by(1)

        expect(flash[:success]).to eq(Spree.t(:successfully_created, scope: :list))
        expect(response).to redirect_to(spree.admin_lists_path)
      end
    end

    # context 'GET #sync subscribers' do
    #   it 'should sync subcribers count of list' do
    #     get :sync_subscribers, params: {
    #       id: list.id
    #     }
    #     list.reload

    #     expect(list.subscribers_count).not_to eq(0)
    #     expect(flash[:success]).to eq(Spree.t(:successfully_synchronize))
    #     expect(response).to redirect_to(spree.admin_lists_path)
    #   end
    # end
  end
end
