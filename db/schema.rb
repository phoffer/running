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

ActiveRecord::Schema.define(version: 20141224022050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "runs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "shoe_id"
    t.integer  "garmin_id"
    t.string   "activity_type"
    t.string   "event_type"
    t.time     "begin_at"
    t.time     "end_at"
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
  end

  add_index "runs", ["shoe_id"], name: "index_runs_on_shoe_id", using: :btree
  add_index "runs", ["user_id"], name: "index_runs_on_user_id", using: :btree

  create_table "shoes", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "miles"
    t.integer  "expectation"
    t.decimal  "cost"
    t.string   "location"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "shoes", ["user_id"], name: "index_shoes_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.json     "accounts"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_foreign_key "runs", "shoes"
  add_foreign_key "runs", "users"
  add_foreign_key "shoes", "users"
end
