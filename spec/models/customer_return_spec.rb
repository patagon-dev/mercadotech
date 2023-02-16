# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::CustomerReturn do
  let(:customer_return) { create(:customer_return) }

  context 'associations' do
    it 'should belongs to vendor' do
      expect(customer_return).to belong_to(:vendor).optional
    end
  end

  context '#after_create' do
    it 'should send notification email to customer' do
      customer_return.order.email = 'spree@example.com'
      customer_return.order.save
      expect { Spree::CustomerReturnMailer.email_notification(customer_return.order_id).deliver_later }.to have_enqueued_mail
    end
  end
end
