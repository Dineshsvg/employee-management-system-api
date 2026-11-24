FactoryBot.define do
  factory :employee do
    name { "John Doe" }
    sequence(:email) { |n| "employee#{n}@example.com" }
    phone { "9876543210" }
    designation { "Software Engineer" }
    salary { 50000 }
    association :department
  end
end
