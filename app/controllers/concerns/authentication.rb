module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
  end

  private

  def authorize_request
    header = request.headers["Authorization"]
    if header.blank?
      render json: { error: "Authentication token is required" }, status: :unauthorized and return
    end

    token = header.split(" ").last
    begin
      decoded = JsonWebToken.decode(token)
      unless decoded && decoded.dig(:user_id)
        render json: { error: "Invalid token structure" }, status: :unauthorized and return
      end

      @current_user = User.find(decoded[:user_id])
    rescue JWT::ExpiredSignature
      render json: { error: "Token expired or session expired" }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    end
  end
end
