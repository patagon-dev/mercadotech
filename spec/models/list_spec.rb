# frozen_string_literal: true

require 'spree_helpers/unit_spec_helper'

RSpec.describe Spree::List do
  let!(:list) { create(:list) }

  context 'associations and validations' do
    it { should belong_to(:store) }
    it { expect(list).to validate_presence_of(:store_id) }
    it { expect(list).to validate_presence_of(:key) }
    it { expect(list).to validate_presence_of(:name) }
  end

  context 'callbacks #after_save' do
    it 'should ensure one default list' do
      list2 = create(:list, default_list: true)

      expect(list2.default_list).to eq(true)
      expect(list.reload.default_list).to eq(false)
    end
  end
end
