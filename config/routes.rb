Rails.application.routes.draw do
  root 'weather_app#index'
  resources :locations
  get '/:id', to: 'weather_app#show' # defined last so it doesn't interfere with other routes
end
