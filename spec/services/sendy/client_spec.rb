# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Sendy::Client do
  # let(:user) { create(:user, email: 'dscecesc@test.co') }
  # let!(:store) { create(:store) }
  # let!(:list) { create(:list, store_id: store.id, key: 'WKmiW892Os7638OVDqp17j3HTg') }

  # describe 'Sendy Client service' do
  #   context 'Check Newsletter Subscription' do
  #     it 'should subscribe to list' do
  #       response = Sendy::Client.new.subscribe(list.key, user.email)

  #       expect(response).to eq(true)
  #     end

  #     it 'should return bounced email response' do
  #       user_new = create(:user, email: 'abc@example.com')
  #       response = Sendy::Client.new.subscribe(list.key, user_new.email)

  #       expect(response).to eq(false)
  #     end
  #   end

  #   context 'Check Newsletter UnSubscription' do
  #     it 'should unsubscribe from list' do
  #       response = Sendy::Client.new.unsubcribe(list.key, user.email)

  #       expect(response).to eq(true)
  #     end

  #     it 'should return email doesnot exist in list' do
  #       user_new = create(:user, email: generate(:random_email))
  #       response = Sendy::Client.new.unsubcribe(list.key, user_new.email)

  #       expect(response).to eq(false)
  #     end
  #   end

  #   context 'Check Newsletter Subscription Status' do
  #     it 'should return subcription status of user in list' do
  #       response = Sendy::Client.new.subscription_status(list.key, user.email)

  #       expect(response).to eq('Unconfirmed')
  #     end
  #   end

  #   context 'Check Newsletter Active Subscriber Count' do
  #     it 'should return active subcribers count of list' do
  #       response = Sendy::Client.new.active_subscriber_count(list.key)

  #       expect(response).to eq('41')
  #     end

  #     it 'should return false response for wrong list' do
  #       list_new = create(:list, default_list: false)
  #       response = Sendy::Client.new.active_subscriber_count(list_new.key)

  #       expect(response).to eq('List does not exist')
  #     end
  #   end
  # end
end
