Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "dashboard", to: "dashboard#index"
  get "badges/:id", to: "badges#show", as: :badge

  resources :contacts
  resources :messages do
    collection do
      get :rekonect
      get :suggestion_reply
    end
    member do
      patch :dismiss
    end
  end

  get "profile", to: "user#show"
  get "up" => "rails/health#show", as: :rails_health_check
end
