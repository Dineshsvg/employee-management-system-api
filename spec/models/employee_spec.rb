require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "validations" do
    subject { build(:employee) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "limits name to 120 characters" do
      subject.name = "A" * 121
      expect(subject).not_to be_valid
    end

    it "requires a valid email" do
      subject.email = "invalid-email"
      expect(subject).not_to be_valid
    end

    it "requires a unique email" do
      create(:employee, email: "john@example.com")
      subject.email = "john@example.com"

      expect(subject).not_to be_valid
    end

    it "normalizes email to lowercase and removes spaces" do
      subject.email = " JOHN@EXAMPLE.COM "
      expect(subject.email).to eq("john@example.com")
    end

    it "requires a phone number" do
      subject.phone = nil
      expect(subject).not_to be_valid
    end

    it "limits phone to 20 characters" do
      subject.phone = "1" * 21
      expect(subject).not_to be_valid
    end

    it "requires a designation" do
      subject.designation = nil
      expect(subject).not_to be_valid
    end

    it "requires a non-negative salary" do
      subject.salary = -1
      expect(subject).not_to be_valid
    end

    it "allows zero salary" do
      subject.salary = 0
      expect(subject).to be_valid
    end

    it "normalizes the employee name" do
      subject.name = "  John Doe  "
      expect(subject.name).to eq("John Doe")
    end
  end

  describe "associations" do
    it "belongs to a department" do
      association = described_class.reflect_on_association(:department)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to a user optionally" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to be true
    end
  end

  describe ".search" do
    let!(:john) do
      create(:employee, name: "John Smith", email: "john@example.com",
                        designation: "Developer")
    end

    let!(:jane) do
      create(:employee, name: "Jane Doe", email: "jane@example.com",
                        designation: "HR Manager")
    end

    it "searches by employee name" do
      expect(described_class.search("John")).to include(john)
    end

    it "searches by email" do
      expect(described_class.search("jane@example.com")).to include(jane)
    end

    it "searches by designation" do
      expect(described_class.search("Developer")).to include(john)
    end

    it "returns all employees for a blank search" do
      expect(described_class.search("")).to contain_exactly(john, jane)
    end

    it "does not treat SQL wildcard characters as search operators" do
      expect(described_class.search("%")).to be_empty
    end
  end
end
