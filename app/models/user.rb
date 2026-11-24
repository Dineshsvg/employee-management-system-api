
class User < ApplicationRecord
  has_secure_password

  has_one :employee, dependent: :restrict_with_error

  ROLES = %w[admin hr employee].freeze

  validates :name, presence: true, length: { maximum: 120 }
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  normalizes :email, with: ->(email) { email.strip.downcase }

  def admin?
    role == "admin"
  end

  def hr?
    role == "hr"
  end

  def employee?
    role == "employee"
  end
end
