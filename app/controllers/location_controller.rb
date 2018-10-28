class LocationController < ApplicationController
  before_action :get_locations
  
  def index
  end
  
  def show
    @location = Location.find(params[:id])
    get_weather_info if @location
    render 'index'
  end
  
  private

    def get_locations
      @locations = Location.all
    end
    
    def get_weather_info
      @weather_request   = WeatherRequestService.new(@location).run
      @weather_info      = @weather_request.weather_info
      @weather_forecasts = @weather_request.weather_forecasts
    end
  
end
