module Spree::SlideDecorator
  def self.prepended(base)
    base.belongs_to :store
  end

  Spree::Slide.prepend self
end
