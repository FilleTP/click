class Consumption < ApplicationRecord
  belongs_to :proposal
  validates :peakpower, presence: true
  validates :angle, presence: true
  validates :loss, presence: true
  validates :slope, presence: true
  validates :azimuth, presence: true
end
