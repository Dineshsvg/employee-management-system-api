require "rails_helper"

RSpec.describe Department, type: :model do
  describe "validations" do
    subject { build(:department) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires a unique name" do
      create(:department, name: "Engineering")
      subject.name = "Engineering"

      expect(subject).not_to be_valid
    end

    it "checks uniqueness without case sensitivity" do
      create(:department, name: "Engineering")
      subject.name = "ENGINEERING"

      expect(subject).not_to be_valid
    end

    it "limits name to 100 characters" do
      subject.name = "A" * 101
      expect(subject).not_to be_valid
    end

    it "normalizes name by removing surrounding spaces" do
      subject.name = "  Engineering  "
      expect(subject.name).to eq("Engineering")
    end
  end

  describe "associations" do
    it "has many employees" do
      association = described_class.reflect_on_association(:employees)
      expect(association.macro).to eq(:has_many)
    end

    it "restricts deletion when employees exist" do
      department = create(:department)
      employee = create(:employee, department: department)

      expect(department.employees.count).to eq(1)

      result = department.destroy

      expect(result).to be false
      expect(department.errors[:base]).to include("Cannot delete record because dependent employees exist")
      expect(Department.exists?(department.id)).to be true
      expect(Employee.exists?(employee.id)).to be true
    end
  end
end
