require "rails_helper"

RSpec.describe "API V1 Authentication", type: :request do
  let!(:user) do
    create(
      :user,
      name: "Test Admin",
      email: "admin@example.com",
      password: "password123",
      role: "admin"
    )
  end

  describe "POST /api/v1/login" do
    context "with valid credentials" do
      it "returns a JWT token and user details" do
        post "/api/v1/login",
             params: {
               email: user.email,
               password: "password123"
             }

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)

        expect(body).to include(
          "token_type" => "Bearer",
          "expires_in" => 24.hours.to_i
        )

        expect(body["token"]).to be_present

        expect(body["user"]).to include(
          "id" => user.id,
          "name" => user.name,
          "email" => user.email,
          "role" => user.role
        )

        expect(body["user"]).not_to have_key("password")
        expect(body["user"]).not_to have_key("password_digest")
      end

      it "generates a valid JWT token" do
        post "/api/v1/login",
             params: {
               email: user.email,
               password: "password123"
             }

        token = JSON.parse(response.body)["token"]

        payload, = JWT.decode(
          token,
          ENV.fetch("JWT_SECRET_KEY") {
            Rails.application.secret_key_base
          },
          true,
          algorithm: "HS256"
        )

        expect(payload["user_id"]).to eq(user.id)
        expect(payload["exp"]).to be > Time.current.to_i
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized for an incorrect password" do
        post "/api/v1/login",
             params: {
               email: user.email,
               password: "wrongpassword"
             }

        expect(response).to have_http_status(:unauthorized)

        expect(JSON.parse(response.body)).to eq(
          "error" => {
            "code" => "invalid_credentials",
            "message" => "Invalid email or password"
          }
        )
      end

      it "returns unauthorized for an unknown email" do
        post "/api/v1/login",
             params: {
               email: "unknown@example.com",
               password: "password123"
             }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized when email is missing" do
        post "/api/v1/login",
             params: {
               password: "password123"
             }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized when password is missing" do
        post "/api/v1/login",
             params: {
               email: user.email
             }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with email normalization" do
      it "allows login with uppercase email" do
        post "/api/v1/login",
             params: {
               email: "ADMIN@EXAMPLE.COM",
               password: "password123"
             }

        expect(response).to have_http_status(:ok)
      end

      it "allows login with surrounding whitespace" do
        post "/api/v1/login",
             params: {
               email: "  admin@example.com  ",
               password: "password123"
             }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
