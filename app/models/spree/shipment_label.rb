class Spree::ShipmentLabel < ApplicationRecord
  validates :label_url, :tracking_number, presence: true
  has_one_attached :enviame_label

  belongs_to :shipment, optional: true
  belongs_to :return_authorization, optional: true
end
