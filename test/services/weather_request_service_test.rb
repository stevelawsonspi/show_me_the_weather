require 'test_helper'

class WeatherRequestServiceTest < ActiveSupport::TestCase

  def setup
    @location                     = Location.first
    @json_valid                   = weather_requests(:good).returned_json
    @json_invalid                 = weather_requests(:bad_invalid_json).returned_json
    @json_from_bad_location_id    = weather_requests(:bad_invalid_location_id).returned_json
    @json_from_location_not_found = weather_requests(:bad_location_not_found).returned_json
  end

  test "valid request" do
    Net::HTTP.expects(:get).returns(@json_valid)
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.returned_json, @json_valid
    assert_equal @weather_request.status,        WeatherRequest::SUCCESS
  end
  
  test "valid request saves weather data" do
    Net::HTTP.expects(:get).returns(@json_valid)
    weather_request = WeatherRequestService.new(@location).run
    weather_info    = weather_request.weather_info
    expected_info   = weather_requests(:good).weather_info
    assert_equal [
      expected_info.weather_time,
      expected_info.temperature,
      expected_info.feels_like,
      expected_info.weather_type,
      expected_info.sunrise,
      expected_info.sunset
    ], 
    [
      weather_info.weather_time,
      weather_info.temperature,
      weather_info.feels_like,
      weather_info.weather_type,
      weather_info.sunrise,
      weather_info.sunset
    ]
    expected_forecasts = expected_info.weather_forecasts.order(:forecast_date)
    weather_info.weather_forecasts.order(:forecast_date).each_with_index do |weather_forecast, index|
      assert_equal [
        expected_forecasts[index].forecast_date,
        expected_forecasts[index].day_name,
        expected_forecasts[index].weather_type,
        expected_forecasts[index].temperature_high,
        expected_forecasts[index].temperature_low,
      ], 
      [
        weather_forecast.forecast_date,
        weather_forecast.day_name,
        weather_forecast.weather_type,
        weather_forecast.temperature_high,
        weather_forecast.temperature_low
      ]
    end
  end
  
  test "handles HTTP error (bad domain in url, etc)" do
    Net::HTTP.expects(:get).raises(StandardError, 'bad url')
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.error_info, 'bad url'
    assert_equal @weather_request.status,     WeatherRequest::ERROR
  end
  
  test "handles invalid json data" do
    Net::HTTP.expects(:get).returns(@json_invalid)
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.returned_json, @invalid_json
    assert_equal @weather_request.status,        WeatherRequest::ERROR
  end
  
  test "detects json with no location info (location unkown to yahoo)" do
    Net::HTTP.expects(:get).returns(@json_from_bad_location_id)
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.returned_json, @json_from_bad_location_id
    assert_equal @weather_request.status,        WeatherRequest::ERROR
  end
  
  test "detects json from bad location id (like non-numeric 'dshfdhjg')" do
    Net::HTTP.expects(:get).returns(@json_from_location_not_found)
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.returned_json, @json_from_location_not_found
    assert_equal @weather_request.status,        WeatherRequest::ERROR
  end

end