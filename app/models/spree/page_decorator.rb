module Spree::PageDecorator
  def self.prepended(base)
    base.include Spree::PageEnums
  end

  Spree::Page.prepend self
end
