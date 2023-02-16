FactoryBot.define do
  factory :shipment_with_enviame, parent: :shipment do
    enviame_carrier_service_id { Spree::EnviameCarrierService.first&.id || create(:enviame_carrier_service).id }
    enviame_carrier_id { Spree::EnviameCarrier.first&.id || create(:enviame_carrier).id }
  end
end
