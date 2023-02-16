class Spree::List < ApplicationRecord
  belongs_to :store
  after_save :ensure_one_default_list

  validates :store_id, :key, :name, presence: true

  scope :default, -> { where(default_list: true) }

  private

  def ensure_one_default_list
    if default_list
      Spree::List.where(default_list: true, store_id: store_id).where.not(id: id).update_all(default_list: false)
    end
  end
end
