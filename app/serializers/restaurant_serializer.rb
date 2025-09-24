class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :phone_number, :email, :description, :total_tables, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer
  has_many :reservations
end
