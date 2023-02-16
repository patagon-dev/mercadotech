module Spree
  class User < Spree::Base
    include UserAddress
    include UserMethods
    include UserPaymentSource

    devise :database_authenticatable, :recoverable,
           :rememberable, :trackable, :encryptable, encryptor: 'authlogic_sha512'
    devise :confirmable if Spree::Auth::Config[:confirmable]
    devise :validatable if Spree::Auth::Config[:validatable]
    devise :registerable
    devise :omniauthable
    devise :saml_authenticatable

    validates_with RutValidator

    acts_as_paranoid
    after_destroy :scramble_email_and_password

    before_validation :set_login

    before_save :formatted_rut
    after_commit :update_guest_user_records, on: :create

    users_table_name = User.table_name
    roles_table_name = Role.table_name

    scope :admin, -> { includes(:spree_roles).where("#{roles_table_name}.name" => 'admin') }

    has_many :bank_accounts, dependent: :destroy
    has_many :return_authorizations, through: :orders

    has_many :spree_store_admin_users, class_name: 'Spree::StoreAdminUser'
    has_many :stores, through: :spree_store_admin_users, class_name: 'Spree::Store'
    has_many :webpay_oneclick_mall_users, class_name: 'Tbk::WebpayOneclickMall::User', foreign_key: :user_id

    def update_guest_user_records
      orders = Spree::Order.where(email: email, user_id: nil)
      bank_accounts = Spree::BankAccount.where(is_guest_user: true, guest_user_email: email, user_id: nil)

      orders.update_all(user_id: id) if orders.any?
      bank_accounts.update_all(is_guest_user: false, user_id: id, guest_user_email: nil) if bank_accounts.any?
    end

    def self.admin_created?
      User.admin.exists?
    end

    def admin?
      has_spree_role?('admin')
    end

    def vendor?
      vendors.active.ids.any?
    end

    protected

    # For SAML
    def password_required?
      false # !persisted? || password.present? || password_confirmation.present?
    end

    private

    def set_login
      # for now force login to be same as email, eventually we will make this configurable, etc.
      self.login ||= email if email
    end

    def formatted_rut
      self.rut = Rut.formatear(rut) if rut.present?
    end

    def scramble_email_and_password
      self.email = SecureRandom.uuid + '@example.net'
      self.login = email
      self.password = SecureRandom.hex(8)
      self.password_confirmation = password
      save
    end
  end
end
