module Api
  module V1
    class DashboardController < ApplicationController
      def index
        total_employees = Employee.count
        total_departments = Department.count

        average_salary = Employee.average(:salary)&.round(2) || 0

        departments = Department
          .left_joins(:employees)
          .select(
            "departments.id",
            "departments.name",
            "COUNT(employees.id) AS employee_count"
          )
          .group("departments.id", "departments.name")
          .order(:name)

        render json: {
          total_employees: total_employees,
          total_departments: total_departments,
          average_salary: average_salary,
          departments: departments.map do |department|
            {
              id: department.id,
              name: department.name,
              employee_count: department.employee_count.to_i
            }
          end
        }
      end
    end
  end
end
