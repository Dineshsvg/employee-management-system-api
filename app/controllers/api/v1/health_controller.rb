module Api
  module V1
    class HealthController < ActionController::API
      def show
        ActiveRecord::Base.connection.execute("SELECT 1")
        render json: { status: "ok", application: "employee_management_system", database: "connected", timestamp: Time.current.iso8601 }
      rescue ActiveRecord::ActiveRecordError
        render json: { status: "error", database: "unavailable" }, status: :service_unavailable
      end
    end
  end
end
