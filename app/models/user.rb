class User < ApplicationRecord
  has_many :reservations, dependent: :destroy
  has_many :chatbot_logs, dependent: :destroy
  has_many :restaurants, dependent: :destroy

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  enum :role, { customer: 0, admin: 1, merchant: 2 }

  def generate_email_verification_token
    begin
      self.email_verification_token = SecureRandom.hex(20)
    end while User.exists?(email_verification_token: self.email_verification_token)

    self.email_verification_sent_at = Time.current
    save!
  end
end
