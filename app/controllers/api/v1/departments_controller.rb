module Api
  module V1
    class DepartmentsController < ApplicationController
      before_action :set_department, only: %i[show update destroy]
      before_action :require_admin!, only: %i[create update destroy]

      def index
        departments = Department.all.order(:id)

        render json: departments
      end

      def show
        render json: @department
      end

      def create
        department = Department.new(department_params)

        if department.save
          render json: department, status: :created
        else
          render json: { errors: department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @department.update(department_params)
          render json: @department
        else
          render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @department.destroy
          head :no_content
        else
          render json: {
          errors: @department.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_department
        @department = Department.find(params[:id])
      end

      def department_params
        params.require(:department).permit(:name)
      end
    end
  end
end
