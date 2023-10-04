Rails.application.routes.draw do 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "store#index"

  resources :companies do 
    resources :social_networks
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get "home/index", to: "home#index"
      resources :companies, only: [:index, :show]
      resources :products, only: [:index, :show]
      resources :categories, only: [:index, :show]
    end
  end

end
