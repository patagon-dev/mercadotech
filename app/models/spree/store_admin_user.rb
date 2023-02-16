module Spree
  class StoreAdminUser < Spree::Base
    belongs_to :store, class_name: 'Spree::Store', required: Spree.version.to_f >= 3.5
    belongs_to :user, class_name: Spree.user_class.name, required: Spree.version.to_f >= 3.5

    validates :store_id, uniqueness: { scope: :user_id }
  end
end
