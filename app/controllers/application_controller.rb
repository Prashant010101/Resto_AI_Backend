class ApplicationController < ActionController::API
  include Authentication

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from JWT::DecodeError, with: :unauthorized

  private
  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unauthorized(exception)
    render json: { error: "Unauthorized: #{exception.message}" }, status: :unauthorized
  end
end
