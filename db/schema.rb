# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_13_062311) do

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "yahoo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weather_forecasts", force: :cascade do |t|
    t.integer "weather_info_id"
    t.string "forecast_date"
    t.string "day_name"
    t.string "weather_type"
    t.integer "temperature_high"
    t.integer "temperature_low"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["weather_info_id"], name: "index_weather_forecasts_on_weather_info_id"
  end

  create_table "weather_infos", force: :cascade do |t|
    t.integer "weather_request_id"
    t.string "weather_time"
    t.string "weather_type"
    t.integer "temperature"
    t.integer "feels_like"
    t.string "sunrise"
    t.string "sunset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["weather_request_id"], name: "index_weather_infos_on_weather_request_id"
  end

  create_table "weather_requests", force: :cascade do |t|
    t.integer "location_id"
    t.string "request_url"
    t.datetime "request_start"
    t.datetime "request_end"
    t.float "request_duration"
    t.string "returned_json"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_info"
    t.index ["location_id"], name: "index_weather_requests_on_location_id"
  end

end
