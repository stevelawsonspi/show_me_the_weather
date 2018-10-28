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
    good_request = WeatherRequest.find_by_status(WeatherRequest::SUCCESS)
    weather_info = OpenStruct.new(weather_time: 'Wed, 24 Oct 2018 06:00 PM AEDT', temperature: 17, feels_like: 16, description: 'Cloudy', sunrise: '6:4 am', sunset: '7:17 pm')
    weather_forecasts = [OpenStruct.new(date: '24 Oct 2018', day_name: 'Wed', temp_high: 18, temp_low: 15, description: 'Mostly Cloudy'),
                         OpenStruct.new(date: '25 Oct 2018', day_name: 'Thu', temp_high: 22, temp_low: 13, description: 'Partly Cloudy'),
                         OpenStruct.new(date: '26 Oct 2018', day_name: 'Fri', temp_high: 21, temp_low: 13, description: 'Mostly Sunny'),
                         OpenStruct.new(date: '27 Oct 2018', day_name: 'Sat', temp_high: 24, temp_low: 13, description: 'Partly Cloudy'),
                         OpenStruct.new(date: '28 Oct 2018', day_name: 'Sun', temp_high: 18, temp_low: 12, description: 'Showers'),
                         OpenStruct.new(date: '29 Oct 2018', day_name: 'Mon', temp_high: 23, temp_low: 11, description: 'Mostly Cloudy'),
                         OpenStruct.new(date: '30 Oct 2018', day_name: 'Tue', temp_high: 26, temp_low: 11, description: 'Sunny'),
                         OpenStruct.new(date: '31 Oct 2018', day_name: 'Wed', temp_high: 25, temp_low: 13, description: 'Mostly Sunny'),
                         OpenStruct.new(date: '01 Nov 2018', day_name: 'Thu', temp_high: 27, temp_low: 16, description: 'Thunderstorms'),
                         OpenStruct.new(date: '02 Nov 2018', day_name: 'Fri', temp_high: 31, temp_low: 19, description: 'Mostly Cloudy')]
    WeatherRequestService.expects(:new).returns(good_request)
    WeatherRequest.any_instance.expects(:run).returns(good_request)
    WeatherRequest.any_instance.expects(:weather_info).returns(weather_info)
    WeatherRequest.any_instance.expects(:weather_forecasts).returns(weather_forecasts)
    get location_path(location)
    assert_template 'location/index'
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
    WeatherRequest.any_instance.expects(:weather_forecasts).returns(weather_forecasts)
    get location_path(location)
    assert_template 'location/index'
    Location.all.each do |location|
      assert_select "tr#location-id-#{location.id}", location.name
    end
    assert_select "div#weather-info", false
    assert_select "div#error-info"
  end
end