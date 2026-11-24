
class Department < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 100 }

  normalizes :name, with: ->(name) { name.strip }
end
