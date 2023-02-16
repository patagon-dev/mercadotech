class Spree::SpiderManagement < ApplicationRecord
  belongs_to :vendor
  has_one_attached :scraped_item_log
end
