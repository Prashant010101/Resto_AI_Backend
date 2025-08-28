class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant
  has_one :payment, dependent: :destroy

  validates :reservation_date, presence: true
  validates :reservation_time, presence: true
  validates :party_size, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: %w[pending confirmed cancelled], message: "%{value} is not a valid status" }
end
