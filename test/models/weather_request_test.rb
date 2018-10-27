require 'test_helper'

class WeatherRequestTest < ActiveSupport::TestCase
  
  def setup
    @location = Location.first
    @weather_request = WeatherRequest.new(location:         Location.first, 
                                          request_url:      "http://someweatherservice.com?location=somethere",
                                          request_start:    Time.now,
                                          request_end:      Time.now + 1.second,
                                          request_duration: 1.0,
                                          returned_json:    '{"some": "json"}',
                                          status:           WeatherRequest::SUCCESS)
    @json_valid = '{"query":{"count":1,"created":"2018-10-24T07:59:56Z","lang":"en-AU","results":{"channel":{"units":{"distance":"mi","pressure":"in","speed":"mph","temperature":"F"},"title":"Yahoo! Weather - Sydney, NSW, AU","link":"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-1105779/","description":"Yahoo! Weather for Sydney, NSW, AU","language":"en-us","lastBuildDate":"Wed, 24 Oct 2018 06:59 PM AEDT","ttl":"60","location":{"city":"Sydney","country":"Australia","region":" NSW"},"wind":{"chill":"61","direction":"158","speed":"19"},"atmosphere":{"humidity":"65","pressure":"1017.0","rising":"0","visibility":"16.1"},"astronomy":{"sunrise":"6:4 am","sunset":"7:17 pm"},"image":{"title":"Yahoo! Weather","width":"142","height":"18","link":"http://weather.yahoo.com","url":"http://l.yimg.com/a/i/brand/purplelogo//uh/us/news-wea.gif"},"item":{"title":"Conditions for Sydney, NSW, AU at 06:00 PM AEDT","lat":"-33.856281","long":"151.020966","link":"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-1105779/","pubDate":"Wed, 24 Oct 2018 06:00 PM AEDT","condition":{"code":"26","date":"Wed, 24 Oct 2018 06:00 PM AEDT","temp":"62","text":"Cloudy"},"forecast":[{"code":"28","date":"24 Oct 2018","day":"Wed","high":"64","low":"59","text":"Mostly Cloudy"},{"code":"30","date":"25 Oct 2018","day":"Thu","high":"72","low":"56","text":"Partly Cloudy"},{"code":"34","date":"26 Oct 2018","day":"Fri","high":"70","low":"55","text":"Mostly Sunny"},{"code":"30","date":"27 Oct 2018","day":"Sat","high":"76","low":"55","text":"Partly Cloudy"},{"code":"11","date":"28 Oct 2018","day":"Sun","high":"64","low":"54","text":"Showers"},{"code":"28","date":"29 Oct 2018","day":"Mon","high":"74","low":"52","text":"Mostly Cloudy"},{"code":"32","date":"30 Oct 2018","day":"Tue","high":"79","low":"52","text":"Sunny"},{"code":"34","date":"31 Oct 2018","day":"Wed","high":"77","low":"56","text":"Mostly Sunny"},{"code":"4","date":"01 Nov 2018","day":"Thu","high":"81","low":"60","text":"Thunderstorms"},{"code":"28","date":"02 Nov 2018","day":"Fri","high":"87","low":"67","text":"Mostly Cloudy"}],"description":"<![CDATA[<img src=\"http://l.yimg.com/a/i/us/we/52/26.gif\"/>\n<BR />\n<b>Current Conditions:</b>\n<BR />Cloudy\n<BR />\n<BR />\n<b>Forecast:</b>\n<BR /> Wed - Mostly Cloudy. High: 64Low: 59\n<BR /> Thu - Partly Cloudy. High: 72Low: 56\n<BR /> Fri - Mostly Sunny. High: 70Low: 55\n<BR /> Sat - Partly Cloudy. High: 76Low: 55\n<BR /> Sun - Showers. High: 64Low: 54\n<BR />\n<BR />\n<a href=\"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-1105779/\">Full Forecast at Yahoo! Weather</a>\n<BR />\n<BR />\n<BR />\n]]>","guid":{"isPermaLink":"false"}}}}}}'
  end

  test "should be valid" do
    assert @weather_request.valid?
  end
  
  test "rejects invalid status" do
    @weather_request.status = 'Invalid'
    refute       @weather_request.valid?
    refute_empty @weather_request.errors[:status]
  end
  
  test "should be able to save" do
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request.save
    end
  end
  
  test "should be able to destroy" do
    @weather_request.save
    assert_difference 'WeatherRequest.count', -1 do
      @weather_request.destroy
    end
  end
  
  test "should extract weather info" do
    expect_info = OpenStruct.new(weather_time: 'Wed, 24 Oct 2018 06:00 PM AEDT', temperature: 17, feels_like: 16, description: 'Cloudy', sunrise: '6:4 am', sunset: '7:17 pm')
    Net::HTTP.expects(:get).returns(@json_valid)
    weather_request = WeatherRequestService.new(@location).run
    weather_info = weather_request.weather_info
    assert_equal weather_info.weather_time, expect_info.weather_time
    assert_equal weather_info.temperature,  expect_info.temperature
    assert_equal weather_info.feels_like,   expect_info.feels_like
    assert_equal weather_info.description,  expect_info.description
    assert_equal weather_info.sunrise,      expect_info.sunrise
    assert_equal weather_info.sunset,       expect_info.sunset
  end
  
  test "should extract weather forecast" do
    expect_forecasts = [OpenStruct.new(date: '24 Oct 2018', day_name: 'Wed', temp_high: 18, temp_low: 15, description: 'Mostly Cloudy'),
                        OpenStruct.new(date: '25 Oct 2018', day_name: 'Thu', temp_high: 22, temp_low: 13, description: 'Partly Cloudy'),
                        OpenStruct.new(date: '26 Oct 2018', day_name: 'Fri', temp_high: 21, temp_low: 13, description: 'Mostly Sunny'),
                        OpenStruct.new(date: '27 Oct 2018', day_name: 'Sat', temp_high: 24, temp_low: 13, description: 'Partly Cloudy'),
                        OpenStruct.new(date: '28 Oct 2018', day_name: 'Sun', temp_high: 18, temp_low: 12, description: 'Showers'),
                        OpenStruct.new(date: '29 Oct 2018', day_name: 'Mon', temp_high: 23, temp_low: 11, description: 'Mostly Cloudy'),
                        OpenStruct.new(date: '30 Oct 2018', day_name: 'Tue', temp_high: 26, temp_low: 11, description: 'Sunny'),
                        OpenStruct.new(date: '31 Oct 2018', day_name: 'Wed', temp_high: 25, temp_low: 13, description: 'Mostly Sunny'),
                        OpenStruct.new(date: '01 Nov 2018', day_name: 'Thu', temp_high: 27, temp_low: 16, description: 'Thunderstorms'),
                        OpenStruct.new(date: '02 Nov 2018', day_name: 'Fri', temp_high: 31, temp_low: 19, description: 'Mostly Cloudy')]
    Net::HTTP.expects(:get).returns(@json_valid)
    weather_request = WeatherRequestService.new(@location).run
    weather_forecasts = weather_request.weather_forecasts
    weather_forecasts.each_with_index do |forecast, index|
      assert_equal forecast.date,        expect_forecasts[index].date,        "forecast index = #{index}"
      assert_equal forecast.day_name,    expect_forecasts[index].day_name,    "forecast index = #{index}"
      assert_equal forecast.temp_high,   expect_forecasts[index].temp_high,   "forecast index = #{index}"
      assert_equal forecast.temp_low,    expect_forecasts[index].temp_low,    "forecast index = #{index}"
      assert_equal forecast.description, expect_forecasts[index].description, "forecast index = #{index}"
    end
  end
end
