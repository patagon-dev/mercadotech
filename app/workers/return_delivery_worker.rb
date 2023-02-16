class ReturnDeliveryWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'compraagil_production_others', retry: false

  def perform(return_authorization_number)
    return_authorization = Spree::ReturnAuthorization.find_by(number: return_authorization_number)
    Enviame::ReturnDelivery.new(return_authorization_number).create unless return_authorization.shipment_label.present?
    Enviame::Pickup.new(return_authorization_number).create if return_authorization.pending_pickup?
  end
end
