# frozen_string_literal: true

FactoryBot.modify do
  factory :address, aliases: %i[bill_address ship_address], class: Spree::Address do
    phone  { '11223344' }
    e_rut  { '10.268.889-9' }
    company { 'Mercadotech' }
    company_business { 'Ecommerce' }
    purchase_order_number { 'PO11223344' }
    company_rut { '10.268.889-9' }
    county { |address| address.association(:county) || Spree::County.last }

    state do |address|
      if address.county
        address.county.state
      else
        address.association(:state)
      end
    end
    street_number { '1518' }
  end
end
