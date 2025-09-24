class Restaurant < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
  validates :total_tables, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
