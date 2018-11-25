class WeatherInfo < ApplicationRecord
  belongs_to :weather_request
  has_many   :weather_forecasts
end
