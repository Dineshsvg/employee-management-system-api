require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) do
    build(
      :user,
      name: "Dinesh",
      email: "Dinesh@example.com",
      role: "admin",
      password: "password123"
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "requires a name" do
      user.name = nil

      expect(user).not_to be_valid
    end

    it "requires a valid email" do
      user.email = "invalid-email"

      expect(user).not_to be_valid
    end

    it "normalizes email" do
      user.valid?

      expect(user.email).to eq("dinesh@example.com")
    end

    it "rejects invalid roles" do
      user.role = "manager"

      expect(user).not_to be_valid
    end

    it "allows employee role" do
      user.role = "employee"

      expect(user).to be_valid
    end

    it "requires password with minimum 8 characters" do
      user.password = "123"

      expect(user).not_to be_valid
    end
  end

  describe "authentication" do
    it "authenticates with correct password" do
      user.save!

      expect(user.authenticate("password123")).to eq(user)
    end

    it "rejects incorrect password" do
      user.save!

      expect(user.authenticate("wrongpassword")).to be_falsey
    end
  end

  describe "roles" do
    it "identifies admin" do
      expect(user).to be_admin
    end

    it "identifies employee" do
      user.role = "employee"

      expect(user).to be_employee
    end
  end
end
