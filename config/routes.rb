Rails.application.routes.draw do
  # user login
  post "/auth/login", to: "sessions#login"
  # User routes
  resources :users, only: [ :index, :show, :create, :update, :destroy ] do
    get "verify_email", on: :collection  # /users/verify_email?token=xyz
  end
  get "users/verify_email", to: "users#verify_email", as: :verify_email
  get "/*a", to: "application#not_found"
end
