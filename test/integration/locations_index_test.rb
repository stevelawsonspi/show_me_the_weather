require 'test_helper'

class LocationsIndexTest < ActionDispatch::IntegrationTest

  test "index (root)" do
    get root_url
    assert_template 'location/index'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
  end
  
  test "location successful" do
    location = Location.first
    good_request = weather_requests(:good)
    WeatherRequestService.expects(:new).returns(good_request)
    WeatherRequest.any_instance.expects(:run).returns(good_request)
    WeatherRequest.any_instance.expects(:weather_info).returns(good_request.weather_info)
    get location_path(location)
    assert_template 'location/show'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
    assert_select "div#weather-info"
    assert_select "div#error-info", false
    weather_forecasts.each do |forecast|
      assert_select "tr#forecast-#{forecast.date.delete(' ')}"
    end
  end
  
  test "location error" do
    location = Location.first
    bad_request = WeatherRequest.find_by_status(WeatherRequest::ERROR)
    weather_info = nil
    weather_forecasts = []
    WeatherRequestService.expects(:new).returns(bad_request)
    WeatherRequest.any_instance.expects(:run).returns(bad_request)
    WeatherRequest.any_instance.expects(:weather_info).returns(weather_info)
    get location_path(location)
    assert_template 'location/show'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
    assert_select "div#weather-info", false
    assert_select "div#error-info"
  end
end