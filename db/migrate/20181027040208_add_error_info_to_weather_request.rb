class AddErrorInfoToWeatherRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_requests, :error_info, :string
  end
end
