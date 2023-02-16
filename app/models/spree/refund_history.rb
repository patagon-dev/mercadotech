class Spree::RefundHistory < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :vendor
  after_commit :schedule_wire_transfer_job, on: :create


  validates_presence_of :reference_number, :amount

  state_machine :status, initial: :pending do
    event :fail do
      transition from: [:pending], to: :failed
    end
    event :complete do
      transition from: [:pending], to: :completed
    end
  end

  def schedule_wire_transfer_job
    if wire_transfer? && refund_response['id_transferencia'].present?
      UpdateWireTransferStatusWorker.perform_in(10.minutes, id)
    end
  end

  def editable?
    status == 'pending'
  end

  private

  def wire_transfer?
    refund_type == 'Spree::WireTransfer'
  end
end
