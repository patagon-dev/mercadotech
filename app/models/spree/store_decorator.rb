module Spree
  module StoreDecorator
    def self.prepended(base)
      base.has_many :store_authentication_types
      base.has_many :authentication_types, through: :store_authentication_types, source: 'authentication_method'
      base.has_many :lists
      base.serialize :invoice_types, Array
      base.validates :invoice_types, presence: true, if: Proc.new { |st|  st.has_attribute?(:invoice_types) }
      base.after_save :clear_products_cache, if: Proc.new { |st| st.has_attribute?(:comment_tool) && st.saved_change_to_comment_tool? }
    end

    def has_active_authentication_type(provider)
      authentication_types.where(active: true, provider: provider).exists?
    end

    private

    def clear_products_cache
      products.update_all(updated_at: Time.zone.now)
    end
  end
end

::Spree::Store.prepend(Spree::StoreDecorator)
