Rails.application.routes.draw do
  resources :assignments
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :memberships
  resources :tasks
  root to: 'visitors#index'
  devise_for :users
  resources :users
end
