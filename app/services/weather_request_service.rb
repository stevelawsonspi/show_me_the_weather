require 'net/http'
require 'json'

class WeatherRequestService

  def initialize(location)
    @location        = location
    @weather_request = setup_request(@location)
    @weather_request.save
  end

  def run
    get_weather_info
    save_weather_info   if keep_processing?
    set_success_status  if keep_processing?
    report_error        if processing_error?
    @weather_request.save
    @weather_request
  end

  private

    def setup_request(location)
      request_url = Rails.configuration.yahoo_weather_url.sub('LOCATION_ID', location.yahoo_id)
      WeatherRequest.new(location: location, request_url: request_url, status: WeatherRequest::PROCESSING)
    end

    def get_weather_info
      call_weather_api
      try_json_to_hash   if keep_processing?
      validate_hash_data if keep_processing?
    end

    def set_success_status
      @weather_request.status = WeatherRequest::SUCCESS
    end

    def keep_processing?
      @weather_request.status == WeatherRequest::PROCESSING
    end
    
    def processing_error?
      @weather_request.status == WeatherRequest::ERROR
    end

    def call_weather_api
      begin
        request_start = Time.now
        returned_json = Net::HTTP.get(URI(@weather_request.request_url))
        request_end   = Time.now
      rescue => error
        @weather_request.assign_attributes(status: WeatherRequest::ERROR, error_info: error.to_s)
      end

      if keep_processing?
        request_duration = request_end - request_start
        @weather_request.assign_attributes(
          request_start:    request_start,
          request_end:      request_end,
          request_duration: request_duration,
          returned_json:    returned_json
        )
      end
    end

    def try_json_to_hash
      begin
        @hash_data = JSON.parse(@weather_request.returned_json)
      rescue => error
        @weather_request.assign_attributes(status: WeatherRequest::ERROR, error_info: error.to_s)
      end
      @hash_data
    end

    def validate_hash_data
      if @hash_data["error"] || !@hash_data.dig('query', 'results', 'channel', 'location')
        @weather_request.assign_attributes(status: WeatherRequest::ERROR, error_info: 'Invalid JSON returned from API')
      end
    end

    def save_weather_info
      save_info
      save_forecasts
    end
    
    def save_info
      wind      = @hash_data.dig('query', 'results', 'channel', 'wind')
      astronomy = @hash_data.dig('query', 'results', 'channel', 'astronomy')
      condition = @hash_data.dig('query', 'results', 'channel', 'item', 'condition')
      @weather_request.create_weather_info(
        weather_time: condition['date'],
        temperature:  to_celsius(condition['temp'].to_f),
        feels_like:   to_celsius(wind['chill'].to_f),
        weather_type: condition['text'],
        sunrise:      astronomy['sunrise'],
        sunset:       astronomy['sunset']
      )
    end

    def save_forecasts
      forecasts = @hash_data.dig('query', 'results', 'channel', 'item', 'forecast')
      forecasts.each do |forecast|
        @weather_request.weather_info.weather_forecasts.create(
          forecast_date:    forecast['date'],
          day_name:         forecast['day'],
          temperature_high: to_celsius(forecast['high'].to_f),
          temperature_low:  to_celsius(forecast['low'].to_f),
          weather_type:     forecast['text']
        )
      end
    end

    def report_error
      # TO-DO: Notify tech support (email, sms, log message, etc)
    end

    def to_celsius(fahrenheit)
      Formulas.fahrenheit_to_celsius(fahrenheit)
    end
end