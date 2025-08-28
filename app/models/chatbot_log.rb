class ChatbotLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :message, presence: true
  validates :sender, inclusion: { in: %w[user bot], message: "%{value} must be 'user' or 'bot'" }
  validates :session_id, presence: true
end
