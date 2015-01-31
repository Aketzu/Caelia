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

ActiveRecord::Schema.define(version: 20150131195129) do

  create_table "recordings", force: :cascade do |t|
    t.string   "basepath"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sourcefiles", force: :cascade do |t|
    t.integer  "recording_id"
    t.integer  "nr"
    t.string   "filename"
    t.decimal  "length",       precision: 10, scale: 2
    t.datetime "recorded_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "sourcefiles", ["recording_id"], name: "index_sourcefiles_on_recording_id"

  create_table "vods", force: :cascade do |t|
    t.string   "name"
    t.integer  "recording_id"
    t.decimal  "start_pos",    precision: 10, scale: 2
    t.decimal  "end_pos",      precision: 10, scale: 2
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.float    "encode_pos"
    t.integer  "status"
  end

  add_index "vods", ["recording_id"], name: "index_vods_on_recording_id"

end
