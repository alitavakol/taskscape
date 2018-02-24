Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'visitors#index'
  resources :projects, only: [:index, :show, :create, :update, :destroy]
  resources :tasks, only: [:index, :show, :create, :update, :destroy]
  resources :assignments, only: [:show, :create, :destroy]
  resources :memberships, only: [:show, :create, :destroy]
  devise_for :users
  resources :users
end
