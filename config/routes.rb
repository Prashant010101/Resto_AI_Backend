Rails.application.routes.draw do
  # user login
  post "/auth/login", to: "sessions#login"
  # User routes
  resources :users, only: [ :index, :show, :create, :update, :destroy ] do
    get "verify_email", on: :collection
  end
  get "/profile", to: "users#profile"
  get "users/verify_email", to: "users#verify_email", as: :verify_email

  resources :restaurants do
    member do
      get :availability
      get :statistics
    end
    collection do
      get :my_restaurants
    end
  end

  get "/*a", to: "application#not_found"
end
