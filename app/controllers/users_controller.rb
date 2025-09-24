class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [ :index, :create, :verify_email ]
  before_action :authorize_request, except: [ :index, :create, :verify_email ]
  before_action :authorize_admin_or_self, only: [ :update, :destroy, :show ]
  def index
    @users = User.all
    if @users.any?
      render json: @users, each_serializer: UserSerializer, status: :ok
    else
      render json: { message: "No data found" }, status: :not_found
    end
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user
      render json: @user, serializer: UserSerializer, status: :ok
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  def profile
    render json: @current_user, serializer: UserSerializer, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.generate_email_verification_token
      UserMailer.email_verification(@user).deliver_now
      render json: { user: @user, status: :created, message: "User created. Please verify your email." }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def verify_email
    user = User.find_by(email_verification_token: params[:token])
    if user && user.email_verification_sent_at > 10.minutes.ago
      user.update(email_verified: true, email_verification_token: nil)
      render json: { message: "Email verified successfully" }, status: :ok
    else
      render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find_by(id: params[:id])
    if @user
      if @user.update(user_params)
        render json: { user: @user }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  def destroy
    @user = User.find_by(id: params[:id])
    if @user
      @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone_number, :role)
  end

  def authorize_admin_or_self
    user = User.find_by(id: params[:id])
    unless user
      render json: { error: "User not found" }, status: :not_found and return
    end

    unless @current_user.role == "admin" || @current_user.id == user.id
      render json: { error: "Not authorized to perform this action" }, status: :forbidden and return
    end
  end
end
