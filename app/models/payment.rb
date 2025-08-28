class Payment < ApplicationRecord
  belongs_to :reservation

  validates :payment_status, inclusion: { in: %w[pending completed failed], message: "%{value} is not a valid status" }
  validates :payment_method, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
