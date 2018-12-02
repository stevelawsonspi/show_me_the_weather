Rails.application.routes.draw do
  root 'weather_app#index'
  get '/:id', to: 'weather_app#show'
end
