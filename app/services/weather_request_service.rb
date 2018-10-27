require 'net/http'
require 'json'

class WeatherRequestService

  def initialize(location)
    @location        = location
    @weather_request = setup_request(@location)
  end

  def run
    get_weather_info
    report_error if processing_error?
    @weather_request.save
    @weather_request
  end

  private

    def get_weather_info
      call_weather_api
      hash_data = try_json_to_hash                       if keep_processing?
      validate_data(hash_data)                           if keep_processing?
      @weather_request.status = WeatherRequest::SUCCESS  if keep_processing?
    end

    def keep_processing?
      @weather_request.status == WeatherRequest::PROCESSING
    end
    
    def processing_error?
      @weather_request.status == WeatherRequest::ERROR
    end

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