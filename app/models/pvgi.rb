class Pvgi < ApplicationRecord
  belongs_to :proposal
  serialize :month1
  serialize :month2
  serialize :month3
  serialize :month4
  serialize :month5
  serialize :month6
  serialize :month7
  serialize :month8
  serialize :month9
  serialize :month10
  serialize :month11
  serialize :month12
end
