class RestaurantsController < ApplicationController
  skip_before_action :authorize_request, only: [ :index, :show ]
  before_action :authorize_request, except: [ :index, :show ]
  before_action :set_restaurant, only: [ :show, :update, :destroy ]
  before_action :authorize_merchant_or_admin, only: [ :create, :update, :destroy ]
  before_action :authorize_owner_or_admin, only: [ :update, :destroy ]

  def index
    @restaurants = Restaurant.includes(:user).all
    if params[:user_id].present?
      @restaurants = @restaurants.where(user_id: params[:user_id])
    end
    if @restaurants.any?
      render json: @restaurants, each_serializer: RestaurantSerializer, status: :ok
    else
      render json: { message: "No restaurants found" }, status: :not_found
    end
  end

  def show
    if @restaurant
      render json: @restaurant, serializer: RestaurantSerializer, status: :ok
    else
      render json: { message: "Restaurant not found" }, status: :not_found
    end
  end

  def create
    @restaurant = current_user_restaurants.build(restaurant_params)

    if @restaurant.save
      render json: @restaurant, serializer: RestaurantSerializer, status: :created
    else
      render json: {
        errors: @restaurant.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      render json: {
        restaurant: restaurant_json(@restaurant),
        message: "Restaurant updated successfully"
      }, status: :ok
    else
      render json: {
        errors: @restaurant.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @restaurant.destroy
      render json: { message: "Restaurant deleted successfully" }, status: :ok
    else
      render json: {
        errors: @restaurant.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # Additional endpoint for merchant's own restaurants
  def my_restaurants
    @restaurants = current_user_restaurants.includes(:reservations)

    render json: {
      restaurants: @restaurants.map do |restaurant|
        restaurant_json(restaurant).merge(
          reservations_count: restaurant.reservations.count,
          pending_reservations: restaurant.reservations.where(status: "pending").count
        )
      end
    }, status: :ok
  end

  # Get restaurant availability
  def availability
    @restaurant = Restaurant.find_by(id: params[:id])

    unless @restaurant
      render json: { message: "Restaurant not found" }, status: :not_found and return
    end

    date = params[:date].present? ? Date.parse(params[:date]) : Date.current

    # Calculate available tables based on reservations
    existing_reservations = @restaurant.reservations
                                     .where(reservation_date: date)
                                     .where(status: [ "confirmed", "pending" ])
                                     .group(:reservation_time)
                                     .sum(:party_size)

    availability_data = generate_time_slots.map do |time_slot|
      reserved_tables = existing_reservations[time_slot] || 0
      available_tables = [ @restaurant.total_tables - reserved_tables, 0 ].max

      {
        time: time_slot.strftime("%H:%M"),
        available_tables: available_tables,
        is_available: available_tables > 0
      }
    end

    render json: {
      restaurant: restaurant_json(@restaurant),
      date: date,
      availability: availability_data
    }, status: :ok
  end

  # Get restaurant statistics (admin/owner only)
  def statistics
    @restaurant = Restaurant.find_by(id: params[:id])

    unless @restaurant
      render json: { message: "Restaurant not found" }, status: :not_found and return
    end

    unless can_access_restaurant_stats?(@restaurant)
      render json: { error: "Not authorized to view restaurant statistics" }, status: :forbidden and return
    end

    stats = {
      total_reservations: @restaurant.reservations.count,
      confirmed_reservations: @restaurant.reservations.where(status: "confirmed").count,
      pending_reservations: @restaurant.reservations.where(status: "pending").count,
      cancelled_reservations: @restaurant.reservations.where(status: "cancelled").count,
      this_month_reservations: @restaurant.reservations.where(
        created_at: Time.current.beginning_of_month..Time.current.end_of_month
      ).count,
      total_revenue: @restaurant.reservations
                               .joins(:payment)
                               .where(payments: { payment_status: "completed" })
                               .sum("payments.amount"),
      average_party_size: @restaurant.reservations.average(:party_size)&.round(2) || 0
    }

    render json: {
      restaurant: restaurant_json(@restaurant),
      statistics: stats
    }, status: :ok
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find_by(id: params[:id])
  end

  def restaurant_params
    params.require(:restaurant).permit(
      :name, :address, :phone_number, :email, :description, :total_tables
    )
  end

  def current_user_restaurants
    case @current_user.role
    when "admin"
      Restaurant.all
    when "merchant"
      @current_user.restaurants
    else
      Restaurant.none
    end
  end

  def authorize_merchant_or_admin
    unless @current_user.role.in?([ "merchant", "admin" ])
      render json: {
        error: "Only merchants and admins can perform this action"
      }, status: :forbidden and return
    end
  end

  def authorize_owner_or_admin
    return if @current_user.role == "admin"

    unless @restaurant && @restaurant.user_id == @current_user.id
      render json: {
        error: "You can only modify your own restaurants"
      }, status: :forbidden and return
    end
  end

  def can_access_restaurant_stats?(restaurant)
    @current_user.role == "admin" || restaurant.user_id == @current_user.id
  end

  def restaurant_json(restaurant)
    {
      id: restaurant.id,
      name: restaurant.name,
      address: restaurant.address,
      phone_number: restaurant.phone_number,
      email: restaurant.email,
      description: restaurant.description,
      total_tables: restaurant.total_tables,
      owner: {
        id: restaurant.user.id,
        name: restaurant.user.name,
        email: restaurant.user.email
      },
      created_at: restaurant.created_at,
      updated_at: restaurant.updated_at
    }
  end

  def generate_time_slots
    # Generate time slots from 9 AM to 10 PM in 30-minute intervals
    start_time = Time.current.beginning_of_day + 9.hours
    end_time = Time.current.beginning_of_day + 22.hours

    time_slots = []
    current_time = start_time

    while current_time <= end_time
      time_slots << current_time
      current_time += 30.minutes
    end

    time_slots
  end
end
