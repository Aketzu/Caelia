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

ActiveRecord::Schema.define(version: 2015_07_31_122428) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], comment: "3", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.bigserial "job_id", null: false
    t.text "job_class", null: false
    t.json "args", default: [], null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error"
    t.text "queue", default: "", null: false
  end

  create_table "recordings", id: :serial, force: :cascade do |t|
    t.string "basepath"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sourcefiles", id: :serial, force: :cascade do |t|
    t.integer "recording_id"
    t.integer "nr"
    t.string "filename"
    t.decimal "length", precision: 10, scale: 2
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recording_id"], name: "index_sourcefiles_on_recording_id"
  end

  create_table "vods", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "recording_id"
    t.decimal "start_pos", precision: 10, scale: 2
    t.decimal "end_pos", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "encode_pos"
    t.integer "status"
    t.integer "elaineid"
    t.index ["recording_id"], name: "index_vods_on_recording_id"
  end

  add_foreign_key "sourcefiles", "recordings"
  add_foreign_key "vods", "recordings"
end
