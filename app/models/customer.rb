class Customer < ApplicationRecord
  has_many :proposals
  validates :name, uniqueness: true
  scope :by_recently_created, -> { order(created_at: :desc) }
  scope :by_oldest_created, -> { order(created_at: :asc) }
  scope :by_name, -> { order(:name) }
end
