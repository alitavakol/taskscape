Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'visitors#index'
  resources :projects
  resources :tasks
  resources :assignments, only: [:index, :new, :show, :create, :destroy]
  resources :memberships, only: [:index, :new, :show, :create, :destroy]
  devise_for :users
  resources :users
end
