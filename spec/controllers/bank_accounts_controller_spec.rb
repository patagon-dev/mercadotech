# frozen_string_literal: true

require 'spree_helpers/controller_spec_helper'

RSpec.describe Spree::BankAccountsController, type: :controller do
  let(:user) { create(:user) }
  let(:bank) { create(:bank) }
  let(:valid_attributes) { { account_number: '5364551', name: 'Juan Mella', email: 'nmella@uc.cl', rut: '53645518', is_default: true, user_id: user.id, bank_id: bank.id, is_guest_user: false } }
  let(:invalid_attributes) { { bank_id: nil } }

  describe 'Bank account CRUDs' do
    before(:each) do
      sign_in user
    end

    describe 'POST #create' do
      it 'should create bank account of user' do
        expect do
          post :create, params: {
            bank_account: valid_attributes
          }
        end.to change { Spree::BankAccount.count }.by(1)

        expect(response).to redirect_to('/account')
      end

      it 'should not create bank account' do
        expect do
          post :create, params: {
            bank_account: invalid_attributes
          }
        end.to change { Spree::BankAccount.count }.by(0)

        expect(response).to render_template(:new)
      end
    end

    describe 'PUT #update' do
      let(:bank_account) { create(:bank_account) }

      it 'update bank account of user' do
        patch :update, params: {
          bank_account: valid_attributes, id: bank_account.id
        }

        expect(response).to redirect_to('/account')
        expect(assigns(:bank_account)).to eq(Spree::BankAccount.first)
      end

      it 'should not create bank account' do
        patch :update, params: {
          bank_account: invalid_attributes, id: bank_account.id
        }

        expect(response).to render_template(:edit)
        expect(assigns(:bank_account)).to eq(Spree::BankAccount.first)
      end
    end

    describe 'GET #new' do
      it 'should initialize bank_account' do
        get :new

        expect(response).to have_http_status(:success)
        expect(assigns(:bank_account)).to be_a_new(Spree::BankAccount)
      end
    end

    describe 'DELETE #destroy' do
      let!(:bank_account) { create(:bank_account, user_id: user.id) }

      it 'should destroy the bank account' do
        expect do
          delete :destroy,
                 params: { id: bank_account.id }
        end.to change { Spree::BankAccount.count }.by(-1)

        expect(flash[:notice]).to include(Spree.t(:successfully_destroyed, scope: :bank_account))
      end
    end
  end
end
