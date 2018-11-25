require 'test_helper'

class WeatherInfoTest < ActiveSupport::TestCase
  
  def setup
    @weather_request = weather_requests(:good).dup
    @weather_request.save
    @weather_info = WeatherInfo.new(
      weather_request_id: @weather_request.id,
      weather_time:       'Wed, 24 Oct 2018 06:00 PM AEDT',
      weather_type:       'Cloudy',
      temperature:        17,
      feels_like:         16,
      sunrise:            '6:4 am',
      sunset:             '7:17 pm'
    )
  end

  test "should be valid" do
    assert @weather_info.valid?
  end
  
  test "should be able to save" do
    assert_difference 'WeatherInfo.count', 1 do
      @weather_info.save
    end
  end
  
  test "should be able to destroy" do
    @weather_info.save
    assert_difference 'WeatherInfo.count', -1 do
      @weather_info.destroy
    end
  end
end
