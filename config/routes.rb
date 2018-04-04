Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'visitors#index'
  resources :projects, only: [:index, :show, :create, :update, :destroy]
  resources :tasks, only: [:index, :show, :create, :update, :destroy]
  resources :assignments, only: [:create, :update, :destroy]
  resources :memberships, only: [:create, :destroy]
  devise_for :users, controllers: { registrations: "registrations" }
  resources :users
end
