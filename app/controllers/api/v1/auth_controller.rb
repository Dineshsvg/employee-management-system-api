module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: :login

      def login
        user = User.find_by(email: params[:email].to_s.strip.downcase)

        if user&.authenticate(params[:password])
          token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, jwt_secret, "HS256")
          render json: {
            token: token,
            token_type: "Bearer",
            expires_in: 24.hours.to_i,
            user: user.slice(:id, :name, :email, :role)
          }
        else
          render json: { error: { code: "invalid_credentials", message: "Invalid email or password" } }, status: :unauthorized
        end
      end

      private

      def jwt_secret
        ENV.fetch("JWT_SECRET_KEY") { Rails.application.secret_key_base }
      end
    end
  end
end
