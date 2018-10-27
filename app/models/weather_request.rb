class WeatherRequest < ApplicationRecord
  belongs_to :location

  STATUSES = [PROCESSING = 'Processing',
              ERROR      = 'Error',
              SUCCESS    = 'Success'].freeze

  validates :status, inclusion: { in: STATUSES }

  def weather_info
    return nil if status != SUCCESS
    hash_data = returned_json_as_hash
    wind      = hash_data.dig('query', 'results', 'channel', 'wind')
    astronomy = hash_data.dig('query', 'results', 'channel', 'astronomy')
    condition = hash_data.dig('query', 'results', 'channel', 'item', 'condition')
    OpenStruct.new(weather_time: condition['date'],
                   temperature:  fahrenheit_to_celsius(condition['temp'].to_f),
                   feels_like:   fahrenheit_to_celsius(wind['chill'].to_f),
                   description:  condition['text'],
                   sunrise:      astronomy['sunrise'],
                   sunset:       astronomy['sunset'])
  end

  def weather_forecasts
    return [] if status != SUCCESS
    hash_data = returned_json_as_hash
    forecasts = hash_data.dig('query', 'results', 'channel', 'item', 'forecast')
    forecast_array = []
    forecasts.each do |forecast|
      forecast_array << OpenStruct.new(date:        forecast['date'],
                                       day_name:    forecast['day'],
                                       temp_high:   fahrenheit_to_celsius(forecast['high'].to_f),
                                       temp_low:    fahrenheit_to_celsius(forecast['low'].to_f),
                                       description: forecast['text'])
    end
    forecast_array
  end

  private

    def returned_json_as_hash
      @hash_data ||= JSON.parse(returned_json)
    end

    def fahrenheit_to_celsius(fahrenheit)
      celsius = ((fahrenheit - 32) * 5.0 / 9.0).round
    end

end
