# frozen_string_literal: true

module Tbk
  module WebpayOneclickMall
    class User < ActiveRecord::Base
      self.table_name = 'webpay_oneclick_mall_users'
      belongs_to :user, class_name: 'Spree::User'
      scope :subscribed, -> { where(subscribed: true) }
      after_save :ensure_one_oneclick_default
      scope :default, -> { where(default: true) }

      SHARES_NUMBERS = %w[1 2 3 4 5 6 8 10 12].freeze

      def subscribed?
        subscribed == true
      end

      def is_credit_card?
        card_type != 'RedCompra'
      end

      # One default_card per oneclick_user
      def ensure_one_oneclick_default
        if default
          Tbk::WebpayOneclickMall::User.where(default: true, user_id: user.id).where.not(id: id).update_all(default: false)
        end
      end
    end
  end
end
