Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      post "login", to: "auth#login"
      get "dashboard", to: "dashboard#index"
      resources :departments
      resources :employees
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
