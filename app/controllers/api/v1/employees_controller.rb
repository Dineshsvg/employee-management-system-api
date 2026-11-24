module Api
  module V1
    class EmployeesController < ApplicationController
      before_action :set_employee, only: %i[show update destroy]
      before_action :require_admin!, only: :destroy

      def index
        page = [ params.fetch(:page, 1).to_i, 1 ].max
        per_page = params.fetch(:per_page, 10).to_i.clamp(1, 50)
        employees = Employee.search(params[:search]).includes(:department).order(:id)
        total_count = employees.count

        render json: {
          data: employees.offset((page - 1) * per_page).limit(per_page).as_json(
            include: { department: { only: %i[id name] } }
          ),
          pagination: {
            current_page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      def show
        render json: @employee.as_json(include: { department: { only: %i[id name] } })
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee, status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: @employee
        else
          render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @employee.destroy!
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(:name, :email, :phone, :designation, :salary, :department_id)
      end
    end
  end
end
