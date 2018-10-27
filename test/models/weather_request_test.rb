require 'test_helper'

class WeatherRequestTest < ActiveSupport::TestCase
  
  def setup
    @weather_request = WeatherRequest.new(location:         Location.first, 
                                          request_url:      "http://someweatherservice.com?location=somethere",
                                          request_start:    Time.now,
                                          request_end:      Time.now + 1.second,
                                          request_duration: 1.0,
                                          returned_json:    '{"some": "json"}',
                                          status:           WeatherRequest::SUCCESS)
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
end
