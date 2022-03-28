# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_28_191700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "que_jobs", comment: "6", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.text "job_class", null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error_message"
    t.text "queue", default: "default", null: false
    t.text "last_error_backtrace"
    t.datetime "finished_at"
    t.datetime "expired_at"
    t.jsonb "args", default: [], null: false
    t.jsonb "data", default: {}, null: false
    t.integer "job_schema_version", null: false
    t.jsonb "kwargs", default: {}, null: false
    t.index ["args"], name: "que_jobs_args_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["data"], name: "que_jobs_data_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["job_class"], name: "que_scheduler_job_in_que_jobs_unique_index", unique: true, where: "(job_class = 'Que::Scheduler::SchedulerJob'::text)"
    t.index ["job_schema_version", "queue", "priority", "run_at", "id"], name: "que_poll_idx", where: "((finished_at IS NULL) AND (expired_at IS NULL))"
    t.index ["kwargs"], name: "que_jobs_kwargs_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.check_constraint "(char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000)", name: "error_length"
    t.check_constraint "(jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND que_validate_tags((data -> 'tags'::text))))", name: "valid_data"
    t.check_constraint "char_length(queue) <= 100", name: "queue_length"
    t.check_constraint "jsonb_typeof(args) = 'array'::text", name: "valid_args"
    t.check_constraint nil, name: "job_class_length"
  end

  create_table "que_lockers", primary_key: "pid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "worker_count", null: false
    t.integer "worker_priorities", null: false, array: true
    t.integer "ruby_pid", null: false
    t.text "ruby_hostname", null: false
    t.text "queues", null: false, array: true
    t.boolean "listening", null: false
    t.integer "job_schema_version", default: 1
    t.check_constraint "(array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL)", name: "valid_queues"
    t.check_constraint "(array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)", name: "valid_worker_priorities"
  end

  create_table "que_scheduler_audit", primary_key: "scheduler_job_id", id: :bigint, default: nil, comment: "6", force: :cascade do |t|
    t.datetime "executed_at", null: false
  end

  create_table "que_scheduler_audit_enqueued", id: false, force: :cascade do |t|
    t.bigint "scheduler_job_id", null: false
    t.string "job_class", limit: 255, null: false
    t.string "queue", limit: 255
    t.integer "priority"
    t.jsonb "args", null: false
    t.bigint "job_id"
    t.datetime "run_at"
    t.index ["args"], name: "que_scheduler_audit_enqueued_args"
    t.index ["job_class"], name: "que_scheduler_audit_enqueued_job_class"
    t.index ["job_id"], name: "que_scheduler_audit_enqueued_job_id"
  end

  create_table "que_values", primary_key: "key", id: :text, force: :cascade do |t|
    t.jsonb "value", default: {}, null: false
    t.check_constraint "jsonb_typeof(value) = 'object'::text", name: "valid_value"
  end

  create_table "recordings", id: :serial, force: :cascade do |t|
    t.string "basepath"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
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
    t.string "youtube"
    t.index ["recording_id"], name: "index_vods_on_recording_id"
  end

  add_foreign_key "que_scheduler_audit_enqueued", "que_scheduler_audit", column: "scheduler_job_id", primary_key: "scheduler_job_id", name: "que_scheduler_audit_enqueued_scheduler_job_id_fkey"
  add_foreign_key "sourcefiles", "recordings"
  add_foreign_key "vods", "recordings"
end
