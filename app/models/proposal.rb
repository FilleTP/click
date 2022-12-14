class Proposal < ApplicationRecord
  belongs_to :customer
  has_many :consumptions, dependent: :destroy
  has_one_attached :building_photo
  has_one_attached :graph_photo
  accepts_nested_attributes_for :consumptions, reject_if: :all_blank, allow_destroy: true
  has_many :pvgis, dependent: :destroy
  validates :due_date, presence: true
  validates :name, presence: true
  validates :shipping_address, presence: true
  validates :postal_code, presence: true
  validates :shipping_city, presence: true
  validates :shipping_province, presence: true
  validates :shipping_country, presence: true
  validates :building_photo, presence: true
  scope :by_recently_created, -> { order(created_at: :desc) }
  scope :by_oldest_created, -> { order(created_at: :asc) }
  scope :by_name, -> { order(:name) }
  scope :by_customer, -> { joins(:customer).order(name: :asc) }

  include PgSearch::Model
    pg_search_scope :global_search,
    against: [ :contact_name, :quote_num ],
    associated_against: {
      customer: :name
    },
    using: {
      tsearch: { prefix: true }
        # highlight: {
        #   StartSel: '<b>',
        #   StopSel: '</b>',
        #   MaxWords: 123,
        #   MinWords: 15,
        #   ShortWord: 3,
        #   HighlightAll: false,
        #   MaxFragments: 3,
        #   FragmentDelimiter: '&hellip;'
        # }
    }
end
