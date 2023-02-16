# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::RefundHistory do
  let!(:refund_history) { create(:refund_history) }

  context 'associations and validations' do
    it { should belong_to(:user).optional }
    it { should belong_to(:vendor) }

    it { expect(refund_history).to validate_presence_of(:reference_number) }
    it { expect(refund_history).to validate_presence_of(:amount) }
  end
end
