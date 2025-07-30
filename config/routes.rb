Rails.application.routes.draw do
  get 'conversations/show'
  get 'users/settings'
  devise_for :users
  get "/goodbye", to: "pages#home", as: :goodbye
  root to: "dashboard#index"
  get "messages/awaiting_answer", to: "messages#awaiting_answer", as: :awaiting_answer_messages
  resources :messages do
    collection do
      get :success
    end
    member do
      patch :dismiss_suggestion
      get :reply
      get :rekonect
      post :send_message
    end
  end
  get 'contacts/circles', to: 'contacts#circles', as: :contact_circles
  resources :contacts
  get 'conversations/:contact_name', to: 'conversations#show', as: :conversation_by_name
  resources :conversations, only: [:show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "dashboard", to: "dashboard#index"
  get "settings", to: "users#settings"

  # Defines the root path route ("/")
  # root "posts#index"
end
