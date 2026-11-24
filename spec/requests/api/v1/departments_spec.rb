require "rails_helper"

RSpec.describe "API V1 Departments", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:hr) { create(:user, role: "hr") }
  let!(:department) { create(:department) }

  def auth_headers(user)
    token = JWT.encode(
      { user_id: user.id },
      ENV.fetch("JWT_SECRET_KEY"),
      "HS256"
    )

    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/departments" do
    it "returns all departments for admin" do
      get "/api/v1/departments", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it "allows HR to view departments" do
      get "/api/v1/departments", headers: auth_headers(hr)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/departments/:id" do
    it "returns a department" do
      get "/api/v1/departments/#{department.id}",
          headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(department.id)
    end

    it "returns 404 for a missing department" do
      get "/api/v1/departments/999999",
          headers: auth_headers(admin)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/departments" do
    it "allows admin to create a department" do
      expect {
        post "/api/v1/departments",
             params: { department: { name: "Engineering" } },
             headers: auth_headers(admin)
      }.to change(Department, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not allow HR to create a department" do
      expect {
        post "/api/v1/departments",
             params: { department: { name: "Engineering" } },
             headers: auth_headers(hr)
      }.not_to change(Department, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "returns validation errors for an invalid department" do
      post "/api/v1/departments",
           params: { department: { name: "" } },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end

  describe "PATCH /api/v1/departments/:id" do
    it "allows admin to update a department" do
      patch "/api/v1/departments/#{department.id}",
            params: { department: { name: "Updated Department" } },
            headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(department.reload.name).to eq("Updated Department")
    end

    it "does not allow HR to update a department" do
      patch "/api/v1/departments/#{department.id}",
            params: { department: { name: "Updated Department" } },
            headers: auth_headers(hr)

      expect(response).to have_http_status(:forbidden)
      expect(department.reload.name).not_to eq("Updated Department")
    end
  end

  describe "DELETE /api/v1/departments/:id" do
    it "allows admin to delete an empty department" do
      expect {
        delete "/api/v1/departments/#{department.id}",
               headers: auth_headers(admin)
      }.to change(Department, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "does not allow HR to delete a department" do
      expect {
        delete "/api/v1/departments/#{department.id}",
               headers: auth_headers(hr)
      }.not_to change(Department, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "does not delete a department with employees" do
      create(:employee, department: department)

      expect {
        delete "/api/v1/departments/#{department.id}",
               headers: auth_headers(admin)
      }.not_to change(Department, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Authentication" do
    it "returns unauthorized without a token" do
      get "/api/v1/departments"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
