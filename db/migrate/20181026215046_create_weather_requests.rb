class CreateWeatherRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :weather_requests do |t|
      t.references :location, foreign_key: true
      t.string :request_url
      t.timestamp :request_start
      t.timestamp :request_end
      t.float :request_duration
      t.string :returned_json
      t.string :status

      t.timestamps
    end
  end
end
