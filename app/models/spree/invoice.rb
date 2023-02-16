class Spree::Invoice < ApplicationRecord
  belongs_to :order
  belongs_to :vendor

  validates :order_id, :vendor_id, presence: true
  validates :document, with: :document_type
  attr_accessor :tipo_dte

  has_one_attached :document
  after_commit :set_filename, on: :create

  TYPES = [33, 39, 52].freeze

  scope :for_vendor, ->(vendor) { where(vendor_id: vendor.id) }

  def document_type
    if document.attached?
      unless document.blob.content_type.starts_with?('application/pdf')
        document.purge rescue ''
        errors[:base] << 'Wrong document format'
      end
    end
  end

  def set_filename
    if document.attached? && !via_superfactura?
      file_type = document.blob.content_type.split('/')[1]
      document.blob.update(filename: "#{tipo_dte}_#{number}.#{file_type}")
    end
  end
end
