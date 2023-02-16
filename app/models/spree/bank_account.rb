class Spree::BankAccount < ApplicationRecord
  validates :account_number, :name, :email, :rut, presence: true
  validates_with RutValidator, BankRutValidator

  belongs_to :user, optional: true
  belongs_to :bank

  delegate :code, to: :bank
  after_save :ensure_one_default_per_user

  scope :default, -> { where(is_default: true) }
  scope :guest_user_account, ->(email) { where(is_guest_user: true, guest_user_email: email) }

  private

  def ensure_one_default_per_user
    if is_default
      Spree::BankAccount.where(is_default: true, user_id: user_id).where.not(id: id).update_all(is_default: false)
    end
  end
end
