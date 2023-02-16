# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::Address do
  let(:address) { create(:address) }

  context 'validations' do
    it 'should return valid RUT response' do
      address.company_rut = '16607830-K'
      expect(address.valid?).to eq(true)

      address.company_rut = '10.268.889-9'
      expect(address.valid?).to eq(true)
    end

    it 'should return invalid RUT response' do
      address.company_rut = '16607830-S'

      expect(address.valid?).to eq(false)
      expect(address.errors.full_messages.join(',')).to eq("Rut #{Spree.t(:invalid_rut)}")
    end

    it 'should validates length of fields' do
      expect(address).to validate_length_of(:e_rut).is_at_most(12)
      expect(address).to allow_value('', nil).for(:e_rut)
      expect(address).to validate_length_of(:phone).is_at_least(8).is_at_most(8)
      expect(address).to validate_length_of(:company).is_at_most(60)
      expect(address).to validate_length_of(:company_business).is_at_most(40)
      expect(address).to validate_length_of(:purchase_order_number).is_at_most(18)
    end
  end

  context 'callbacks' do
    context '#before_save' do
      it 'should format company_rut' do
        address.company_rut = '16607830K'
        address.save
        expect(address.company_rut).to eq(Rut.formatear('16607830K'))
      end
    end
  end
end
