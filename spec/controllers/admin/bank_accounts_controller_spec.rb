# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::Admin::BankAccountsController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }
  let(:bank_account) { create(:bank_account, user_id: user.id) }
  let(:order) { create(:shipped_order) }

  describe 'BankAccount' do
    before(:each) do
      sign_in(admin_user)
    end

    context 'GET #index' do
      it 'should load user bank accounts' do
        order.user_id = user.id
        order.save

        get :index, params: {
          order_id: order.number
        }

        expect(response).to have_http_status(:success)
        expect(assigns(:bank_accounts)).to eq(user.bank_accounts)
      end
    end

    context 'GET #new' do
      it 'should create bank account instance' do
        get :new, params: {
          order_id: order.number
        }

        expect(response).to have_http_status(:success)
        expect(assigns(:bank_account)).to be_a_new(Spree::BankAccount)
      end
    end

    context 'POST #create' do
      let(:bank) { create(:bank) }
      let(:valid_attributes) do
        {
          bank_account: {
            bank_id: bank.id, account_number: '5364551', name: 'Juan Mella', email: 'rahul@bluebash.co', rut: '53645518', is_default:  '1'
          },
          order_id: order.number
        }
      end
      let(:invalid_attributes) do
        {
          bank_account: {
            bank_id: bank.id, account_number: '5364551'
          },
          order_id: order.number
        }
      end

      before do
        order.user_id = user.id
        order.save
      end

      it 'should create bank account' do
        expect do
          post :create, params: valid_attributes
        end.to change { Spree::BankAccount.count }.by(1)

        expect(response).to redirect_to(spree.admin_order_bank_accounts_path(order))
      end

      it 'should not create bank account' do
        expect do
          post :create, params: invalid_attributes
        end.to change { Spree::BankAccount.count }.by(0)

        expect(response).to render_template(:new)
      end
    end
  end
end
