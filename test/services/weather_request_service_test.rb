require 'test_helper'

class WeatherRequestServiceTest < ActiveSupport::TestCase

  def setup
    @location = Location.first
    @json_valid = '{"query":{"count":1,"created":"2018-10-24T07:59:56Z","lang":"en-AU","results":{"channel":{"units":{"distance":"mi","pressure":"in","speed":"mph","temperature":"F"},"title":"Yahoo! Weather - Sydney, NSW, AU","link":"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-1105779/","description":"Yahoo! Weather for Sydney, NSW, AU","language":"en-us","lastBuildDate":"Wed, 24 Oct 2018 06:59 PM AEDT","ttl":"60","location":{"city":"Sydney","country":"Australia","region":" NSW"},"wind":{"chill":"61","direction":"158","speed":"19"},"atmosphere":{"humidity":"65","pressure":"1017.0","rising":"0","visibility":"16.1"},"astronomy":{"sunrise":"6:4 am","sunset":"7:17 pm"},"image":{"title":"Yahoo! Weather","width":"142","height":"18","link":"http://weather.yahoo.com","url":"http://l.yimg.com/a/i/brand/purplelogo//uh/us/news-wea.gif"},"item":{"title":"Conditions for Sydney, NSW, AU at 06:00 PM AEDT","lat":"-33.856281","long":"151.020966","link":"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-1105779/","pubDate":"Wed, 24 Oct 2018 06:00 PM AEDT","condition":{"code":"26","date":"Wed, 24 Oct 2018 06:00 PM AEDT","temp":"62","text":"Cloudy"},"forecast":[{"code":"28","date":"24 Oct 2018","day":"Wed","high":"64","low":"59","text":"Mostly Cloudy"},{"code":"30","date":"25 Oct 2018","day":"Thu","high":"72","low":"56","text":"Partly Cloudy"},{"code":"34","date":"26 Oct 2018","day":"Fri","high":"70","low":"55","text":"Mostly Sunny"},{"code":"30","date":"27 Oct 2018","day":"Sat","high":"76","low":"55","text":"Partly Cloudy"},{"code":"11","date":"28 Oct 2018","day":"Sun","high":"64","low":"54","text":"Showers"},{"code":"28","date":"29 Oct 2018","day":"Mon","high":"74","low":"52","text":"Mostly Cloudy"},{"code":"32","date":"30 Oct 2018","day":"Tue","high":"79","low":"52","text":"Sunny"},{"code":"34","date":"31 Oct 2018","day":"Wed","high":"77","low":"56","text":"Mostly Sunny"},{"code":"4","date":"01 Nov 2018","day":"Thu","high":"81","low":"60","text":"Thunderstorms"},{"code":"28","date":"02 Nov 2018","day":"Fri","high":"87","low":"67","text":"Mostly Cloudy"}],"description":"<![CDATA[<img src=\"http://l.yimg.com/a/i/us/we/52/26.gif\"/>\n<BR />\n<b>Current Conditions:</b>\n<BR />Cloudy\n<BR />\n<BR />\n<b>Forecast:</b>\n<BR /> Wed - Mostly Cloudy. High: 64Low: 59\n<BR /> Thu - Partly Cloudy. High: 72Low: 56\n<BR /> Fri - Mostly Sunny. High: 70Low: 55\n<BR /> Sat - Partly Cloudy. High: 76Low: 55\n<BR /> Sun - Showers. High: 64Low: 54\n<BR />\n<BR />\n<a href=\"http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*https://weather.yahoo.com/country/state/city-1105779/\">Full Forecast at Yahoo! Weather</a>\n<BR />\n<BR />\n<BR />\n]]>","guid":{"isPermaLink":"false"}}}}}}'
    @json_from_bad_location_id = '{"query":{"count":1,"created":"2018-10-27T06:13:26Z","lang":"en-AU","results":{"channel":{"units":{"distance":"mi","pressure":"in","speed":"mph","temperature":"F"}}}}}'
    @json_where_location_not_found = '{"error":{"lang":"en-US","description":"Invalid identfier asdfghjkl. me AND me.ip are the only supported identifier in this context"}}'
    @invalid_json = '{ "really bad" { "json"'
  end

  test "valid request" do
    Net::HTTP.expects(:get).returns(@json_valid)
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.returned_json, @json_valid
    assert_equal @weather_request.status,        WeatherRequest::SUCCESS
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
    Net::HTTP.expects(:get).returns(@invalid_json)
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
    Net::HTTP.expects(:get).returns(@json_where_location_not_found)
    assert_difference 'WeatherRequest.count', 1 do
      @weather_request = WeatherRequestService.new(@location).run
    end
    assert_equal @weather_request.returned_json, @json_where_location_not_found
    assert_equal @weather_request.status,        WeatherRequest::ERROR
  end

end