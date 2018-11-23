class CreateWeatherForecasts < ActiveRecord::Migration[5.2]
  def change
    create_table :weather_forecasts do |t|
      t.references :weather_info, foreign_key: true
      t.string :forecast_date
      t.string :day_name
      t.string :weather_type
      t.integer :temperature_high
      t.integer :temperature_low

      t.timestamps
    end
  end
end
