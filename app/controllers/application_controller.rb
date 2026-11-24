class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: { code: "not_found", message: "Resource not found" } }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { error: { code: "bad_request", message: error.message } }, status: :bad_request
  end

  attr_reader :current_user

  private

  def authenticate_user!
    header = request.headers["Authorization"].to_s
    scheme, token = header.split(" ", 2)

    unless scheme&.casecmp("Bearer")&.zero? && token.present?
      return render json: { error: { code: "unauthorized", message: "Bearer token required" } }, status: :unauthorized
    end

    payload, = JWT.decode(token, jwt_secret, true, algorithm: "HS256")
    @current_user = User.find(payload.fetch("user_id"))
  rescue JWT::DecodeError, KeyError, ActiveRecord::RecordNotFound
    render json: { error: { code: "unauthorized", message: "Invalid or expired token" } }, status: :unauthorized
  end

  def require_admin!
    return if current_user&.admin?

    render json: { error: { code: "forbidden", message: "Admin access required" } }, status: :forbidden
  end

  def jwt_secret
    ENV.fetch("JWT_SECRET_KEY") { Rails.application.secret_key_base }
  end
end
