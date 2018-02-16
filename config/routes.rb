Rails.application.routes.draw do
  namespace :admin do
    resources :users

    root to: "users#index"
  end

  root to: 'visitors#index'
  devise_for :users
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
