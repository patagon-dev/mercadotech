module Spree::AddressDecorator
  BILL_ADDRESS_FIELDS = %w[document_type company_rut company company_business address1 street_number address2 state county country firstname lastname phone].freeze
  SHIP_ADDRESS_FIELDS = %w[firstname lastname phone address1 street_number address2 state county country].freeze
  COMPANY_FIELDS = %w[company company_rut company_business].freeze

  def self.prepended(base)
    base.clear_validators!
    base.before_validation :clear_invalid_state_entities, if: -> { country.present? }, on: :update

    base.with_options presence: true do
      validates :firstname, :lastname, :address1, :country
      validates :zipcode, if: :require_zipcode?
      validates :phone, if: :require_phone?
    end

    base.validate :state_validate, :postal_code_validate

    base.validates_with RutValidator
    base.before_save :formatted_rut
    base.validates_length_of :e_rut, maximum: 12, allow_blank: true
    base.validates_length_of :phone, maximum: 8, minimum: 8
    base.validates_length_of :company, maximum: 60
    base.validates_length_of :company_business, maximum: 40
    base.validates_length_of :purchase_order_number, maximum: 18
  end

  def full_street_address
    [address1, street_number, address2].compact.join(', ')
  end

  def return_pickup_address
    [full_name, full_street_address, county.name].compact.join(', ')
  end

  private

  def formatted_rut
    self.company_rut = Rut.formatear(company_rut.strip) if company_rut.present?
  end

  def state_validate
    return if country.blank? || !Spree::Config[:address_requires_state]
    return unless country.states_required
  end

  Spree::Address.prepend self
end
