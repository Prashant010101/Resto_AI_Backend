class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone_number, :role, :email_verified, :created_at, :updated_at

  has_many :restaurants
  has_many :reservations
  has_many :chatbot_logs
end
