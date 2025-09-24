class SessionsController < ApplicationController
  skip_before_action :authorize_request, only: [ :login ]
  def login
    @user = User.find_by_email(params[:email])
    unless @user.presence
      render json: { error: "User not found" }, status: :not_found and return
    end
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     username: @user.name }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
