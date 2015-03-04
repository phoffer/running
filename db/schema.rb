# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150214204844) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "laps", force: :cascade do |t|
    t.integer  "run_id"
    t.integer  "number"
    t.datetime "begin_at"
    t.datetime "end_at"
    t.float    "distance"
    t.float    "duration"
    t.float    "mean_heart_rate"
    t.float    "mean_pace"
    t.float    "mean_stride_length"
    t.float    "mean_cadence"
    t.float    "mean_gct"
    t.float    "mean_vertical_oscillation"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.float    "elevation_gain"
    t.float    "elevation_loss"
    t.float    "temp"
    t.float    "high"
    t.float    "low"
    t.float    "humidity"
    t.string   "station_ids"
    t.float    "incline"
  end

  add_index "laps", ["run_id"], name: "index_laps_on_run_id", using: :btree

  create_table "readings", force: :cascade do |t|
    t.integer  "weather_id"
    t.string   "pws_id"
    t.datetime "time"
    t.float    "temp"
    t.float    "humidity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "readings", ["weather_id"], name: "index_readings_on_weather_id", using: :btree

  create_table "runs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "shoe_id"
    t.integer  "garmin_id"
    t.string   "activity_type"
    t.string   "event_type"
    t.datetime "begin_at"
    t.datetime "end_at"
    t.string   "time_zone"
    t.float    "distance"
    t.float    "duration"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "mean_heart_rate"
    t.float    "mean_pace"
    t.float    "mean_stride_length"
    t.float    "mean_cadence"
    t.float    "mean_gct"
    t.float    "mean_vertical_oscillation"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.float    "elevation_gain"
    t.float    "elevation_loss"
    t.float    "temp"
    t.float    "high"
    t.float    "low"
    t.float    "humidity"
    t.string   "station_ids"
    t.float    "incline"
  end

  add_index "runs", ["garmin_id"], name: "index_runs_on_garmin_id", using: :btree
  add_index "runs", ["shoe_id"], name: "index_runs_on_shoe_id", using: :btree
  add_index "runs", ["user_id"], name: "index_runs_on_user_id", using: :btree

  create_table "shoes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "brand"
    t.string   "model"
    t.integer  "version"
    t.string   "letter",      limit: 1, default: "a"
    t.integer  "status",                default: 0
    t.float    "miles",                 default: 0.0
    t.integer  "expectation"
    t.string   "defaults",                                         array: true
    t.decimal  "cost"
    t.string   "location"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "color"
  end

  add_index "shoes", ["user_id"], name: "index_shoes_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.json     "accounts"
    t.json     "settings"
    t.json     "goal_race"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "weathers", force: :cascade do |t|
    t.float    "temp"
    t.float    "high"
    t.float    "low"
    t.float    "humidity"
    t.string   "station_ids",               array: true
    t.integer  "running_id"
    t.string   "running_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "weathers", ["running_type", "running_id"], name: "index_weathers_on_running_type_and_running_id", using: :btree

  add_foreign_key "laps", "runs"
  add_foreign_key "readings", "weathers"
  add_foreign_key "runs", "shoes"
  add_foreign_key "runs", "users"
  add_foreign_key "shoes", "users"
end
