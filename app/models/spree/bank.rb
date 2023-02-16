class Spree::Bank < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true
end
