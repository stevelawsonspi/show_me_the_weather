require 'test_helper'

class WeatherForecastTest < ActiveSupport::TestCase
   
  def setup
    @weather_request = weather_requests(:good).dup
    @weather_request.save
    @weather_info = WeatherInfo.create(
      weather_request_id: @weather_request.id,
      weather_time:       'Wed, 24 Oct 2018 06:00 PM AEDT',
      weather_type:       'Cloudy',
      temperature:        17,
      feels_like:         16,
      sunrise:            '6:4 am',
      sunset:             '7:17 pm'
    )
    @weather_forecast = WeatherForecast.new(
      weather_info_id:    @weather_info.id,
      forecast_date:      '24 Oct 2018',
      day_name:           'Wed',
      weather_type:       'Mostly Cloudy',
      temperature_high:   18,
      temperature_low:    15
    )
  end

  test "should be valid" do
    assert @weather_forecast.valid?
  end

  test "should be able to save" do
    assert_difference 'WeatherForecast.count', 1 do
      @weather_forecast.save
    end
  end

  test "should be able to destroy" do
    @weather_forecast.save
    assert_difference 'WeatherForecast.count', -1 do
      @weather_forecast.destroy
    end
  end
end
