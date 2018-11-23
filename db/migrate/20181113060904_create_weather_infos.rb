class CreateWeatherInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :weather_infos do |t|
      t.references :weather_request, foreign_key: true
      t.string :weather_time
      t.string :weather_type
      t.integer :temperature
      t.integer :feels_like
      t.string :sunrise
      t.string :sunset

      t.timestamps
    end
  end
end
