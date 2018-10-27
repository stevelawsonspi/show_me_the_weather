require 'net/http'
require 'json'

class WeatherRequestService

  def initialize(location)
    @location        = location
    @weather_request = setup_request(@location)
  end

  def run
    call_weather_api
    hash_data = try_json_to_hash                       if @weather_request.status == WeatherRequest::PROCESSING
    validate_data(hash_data)                           if @weather_request.status == WeatherRequest::PROCESSING
    @weather_request.status = WeatherRequest::SUCCESS  if @weather_request.status == WeatherRequest::PROCESSING
    report_error                                       if @weather_request.status == WeatherRequest::ERROR
    @weather_request.save
    @weather_request
  end

  private

    def setup_request(location)
      request_url = Rails.configuration.yahoo_weather_url.sub('LOCATION_ID', location.yahoo_id)
      WeatherRequest.create(location: location, request_url: request_url, status: WeatherRequest::PROCESSING)
    end

    def call_weather_api
      begin
        request_start = Time.now
        returned_json = Net::HTTP.get(URI(@weather_request.request_url))
        request_end   = Time.now
      rescue => error
        @weather_request.assign_attributes(status: WeatherRequest::ERROR, error_info: error.to_s)
      end
      if @weather_request.status == WeatherRequest::PROCESSING
        request_duration = request_end - request_start
        @weather_request.assign_attributes(request_start: request_start, request_end: request_end, request_duration: request_duration, returned_json: returned_json)
      end
    end

    def try_json_to_hash
      begin
        hash_data = JSON.parse(@weather_request.returned_json)
      rescue => error
        @weather_request.assign_attributes(status: WeatherRequest::ERROR, error_info: error.to_s)
      end
      hash_data
    end

    def validate_data(hash_data)
      if hash_data["error"] || !hash_data.dig('query', 'results', 'channel', 'location')
        @weather_request.assign_attributes(status: WeatherRequest::ERROR, error_info: 'Invalid JSON returned from API')
      end
    end
    
    def report_error
      # TO-DO: Notify tech support (email, sms, log message, etc)
    end
    
end