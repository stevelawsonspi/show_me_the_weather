class LocationController < ApplicationController
  before_action :get_locations
  
  def index
  end
  
  def show
    @location = Location.find_by_id(params[:id])
    if @location
      get_weather_info
    else
      redirect_to root_path
    end
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
