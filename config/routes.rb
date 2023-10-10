Rails.application.routes.draw do 
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
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
      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :products, only: [:index, :show, :create, :update, :destroy]
     
    end
  end

end
