require 'test_helper'

class WeatherAppIndexTest < ActionDispatch::IntegrationTest

  test "index (root)" do
    get root_url
    assert_response :success
    assert_template 'weather_app/index'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
  end
  
  test "location successful" do
    location = Location.first
    good_request = weather_requests(:good)
    WeatherRequestService.expects(:new).returns(good_request)
    WeatherRequest.any_instance.expects(:run).returns(good_request)
    get "/#{location.id}"
    assert_response :success
    assert_template 'weather_app/show'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
    assert_select "div#weather-info"
    assert_select "div#error-info", false
    weather_forecasts.each do |forecast|
      assert_select "tr#forecast-#{forecast.id}"
    end
  end
  
  test "location error" do
    location = Location.first
    bad_request = weather_requests(:bad_location_not_found)
    WeatherRequestService.expects(:new).returns(bad_request)
    WeatherRequest.any_instance.expects(:run).returns(bad_request)
    get "/#{location.id}"
    assert_response :success
    assert_template 'weather_app/show'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
    assert_select "div#weather-info", false
    assert_select "div#error-info"
  end
end