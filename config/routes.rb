Rails.application.routes.draw do
  root 'location#index'
  resources :location, only: [:index, :show]
end
