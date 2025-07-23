Rails.application.routes.draw do
  get 'users/settings'
  devise_for :users
  root to: "pages#home"
  get "messages/awaiting_answer", to: "messages#awaiting_answer", as: :awaiting_answer_messages
  resources :messages do
    member do
      patch :dismiss_suggestion
      get :reply
      get :rekonect
    end
  end
  get 'contacts/circles', to: 'contacts#circles', as: :contact_circles
  resources :contacts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "dashboard", to: "dashboard#index"
  get "settings", to: "users#settings"

  # Defines the root path route ("/")
  # root "posts#index"
end
