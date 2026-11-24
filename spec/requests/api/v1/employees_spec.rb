require "rails_helper"

RSpec.describe "API V1 Employees", type: :request do
  let(:admin) { create(:user, role: "admin") }
  let(:department) { create(:department) }

  def auth_headers(user)
    secret = ENV.fetch("JWT_SECRET_KEY") {
      Rails.application.secret_key_base
    }

    token = JWT.encode(
      { user_id: user.id },
      secret,
      "HS256"
    )

    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/employees" do
    it "returns all employees with pagination" do
      employee = create(:employee, department: department)

      get "/api/v1/employees", headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["data"].length).to eq(1)
      expect(json["data"].first["id"]).to eq(employee.id)
      expect(json["data"].first["department"]["name"]).to eq(department.name)

      expect(json["pagination"]["current_page"]).to eq(1)
      expect(json["pagination"]["per_page"]).to eq(10)
      expect(json["pagination"]["total_count"]).to eq(1)
    end

    it "filters employees by search term" do
      matching = create(
        :employee,
        name: "John Smith",
        department: department
      )

      create(
        :employee,
        name: "Jane Doe",
        department: department
      )

      get "/api/v1/employees",
          params: { search: "John" },
          headers: auth_headers(admin)

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |item| item["id"] }).to eq([ matching.id ])
    end

    it "supports pagination" do
      3.times { create(:employee, department: department) }

      get "/api/v1/employees",
          params: { page: 1, per_page: 2 },
          headers: auth_headers(admin)

      json = JSON.parse(response.body)

      expect(json["data"].length).to eq(2)
      expect(json["pagination"]["per_page"]).to eq(2)
      expect(json["pagination"]["total_count"]).to eq(3)
      expect(json["pagination"]["total_pages"]).to eq(2)
    end

    it "limits per_page to 50" do
      get "/api/v1/employees",
          params: { per_page: 100 },
          headers: auth_headers(admin)

      json = JSON.parse(response.body)

      expect(json["pagination"]["per_page"]).to eq(50)
    end
  end

  describe "GET /api/v1/employees/:id" do
    it "returns an employee" do
      employee = create(:employee, department: department)

      get "/api/v1/employees/#{employee.id}",
          headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["id"]).to eq(employee.id)
      expect(json["name"]).to eq(employee.name)
      expect(json["department"]["name"]).to eq(department.name)
    end

    it "returns 404 for a missing employee" do
      get "/api/v1/employees/999999",
          headers: auth_headers(admin)

      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body)
      expect(json.dig("error", "code")).to eq("not_found")
    end
  end

  describe "POST /api/v1/employees" do
    let(:valid_attributes) do
      {
        name: "John Smith",
        email: "john@example.com",
        phone: "9876543210",
        designation: "Developer",
        salary: 50000,
        department_id: department.id
      }
    end

    it "creates an employee" do
      expect {
        post "/api/v1/employees",
             params: { employee: valid_attributes },
             headers: auth_headers(admin),
             as: :json
      }.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["name"]).to eq("John Smith")
    end

    it "returns validation errors for invalid attributes" do
      invalid_attributes = valid_attributes.merge(name: "")

      post "/api/v1/employees",
           params: { employee: invalid_attributes },
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Name can't be blank")
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    let(:employee) do
      create(:employee, department: department)
    end

    it "updates an employee" do
      patch "/api/v1/employees/#{employee.id}",
            params: {
              employee: { designation: "Senior Developer" }
            },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(employee.reload.designation).to eq("Senior Developer")
    end

    it "returns validation errors for invalid updates" do
      patch "/api/v1/employees/#{employee.id}",
            params: {
              employee: { name: "" }
            },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    it "allows an admin to delete an employee" do
      employee = create(:employee, department: department)

      expect {
        delete "/api/v1/employees/#{employee.id}",
               headers: auth_headers(admin)
      }.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "prevents an HR user from deleting an employee" do
      hr_user = create(:user, role: "hr")
      employee = create(:employee, department: department)

      expect {
        delete "/api/v1/employees/#{employee.id}",
               headers: auth_headers(hr_user)
      }.not_to change(Employee, :count)

      expect(response).to have_http_status(:forbidden)

      json = JSON.parse(response.body)
      expect(json.dig("error", "code")).to eq("forbidden")
    end
  end

  describe "authentication" do
    it "rejects requests without a Bearer token" do
      get "/api/v1/employees"

      expect(response).to have_http_status(:unauthorized)

      json = JSON.parse(response.body)
      expect(json.dig("error", "code")).to eq("unauthorized")
    end
  end
end
