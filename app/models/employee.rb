
class Employee < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :department

  validates :name, presence: true, length: { maximum: 120 }
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone, presence: true, length: { maximum: 20 }
  validates :designation, presence: true, length: { maximum: 100 }
  validates :salary, numericality: { greater_than_or_equal_to: 0 }

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.strip }

  scope :search, ->(term) {
    return all if term.blank?

    pattern = "%#{sanitize_sql_like(term.to_s.strip)}%"

    where(
      "employees.name ILIKE :term OR employees.email ILIKE :term OR employees.designation ILIKE :term",
      term: pattern
    )
  }
end
