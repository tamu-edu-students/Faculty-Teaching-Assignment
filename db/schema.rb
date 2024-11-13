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

ActiveRecord::Schema[7.2].define(version: 2024_11_11_015305) do
  create_table "courses", force: :cascade do |t|
    t.string "course_number"
    t.integer "max_seats"
    t.string "lecture_type"
    t.integer "num_labs"
    t.integer "schedule_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hide", default: false, null: false
    t.index ["schedule_id"], name: "index_courses_on_schedule_id"
  end

  create_table "instructor_preferences", force: :cascade do |t|
    t.integer "instructor_id", null: false
    t.integer "preference_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course_id", null: false
    t.index ["course_id"], name: "index_instructor_preferences_on_course_id"
    t.index ["instructor_id"], name: "index_instructor_preferences_on_instructor_id"
  end

  create_table "instructors", force: :cascade do |t|
    t.integer "id_number"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "email"
    t.boolean "before_9"
    t.boolean "after_3"
    t.text "beaware_of"
    t.integer "schedule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_course_load"
    t.index ["schedule_id"], name: "index_instructors_on_schedule_id"
  end

  create_table "room_bookings", force: :cascade do |t|
    t.integer "room_id", null: false
    t.integer "time_slot_id", null: false
    t.boolean "is_available", default: true
    t.boolean "is_lab"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "instructor_id"
    t.integer "section_id"
    t.boolean "is_locked"
    t.index ["instructor_id"], name: "index_room_bookings_on_instructor_id"
    t.index ["room_id"], name: "index_room_bookings_on_room_id"
    t.index ["section_id"], name: "index_room_bookings_on_section_id"
    t.index ["time_slot_id"], name: "index_room_bookings_on_time_slot_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "campus"
    t.boolean "is_lecture_hall"
    t.boolean "is_learning_studio"
    t.boolean "is_lab"
    t.string "building_code"
    t.string "room_number"
    t.integer "capacity"
    t.boolean "is_active"
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "schedule_id", default: -1, null: false
    t.index ["schedule_id"], name: "index_rooms_on_schedule_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "schedule_name"
    t.string "semester_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.string "section_number"
    t.integer "seats_alloted"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_sections_on_course_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.string "day"
    t.string "start_time"
    t.string "end_time"
    t.string "slot_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "provider"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "courses", "schedules"
  add_foreign_key "instructor_preferences", "courses"
  add_foreign_key "instructor_preferences", "instructors"
  add_foreign_key "instructors", "schedules"
  add_foreign_key "room_bookings", "instructors"
  add_foreign_key "room_bookings", "rooms"
  add_foreign_key "room_bookings", "sections"
  add_foreign_key "room_bookings", "time_slots"
  add_foreign_key "rooms", "schedules"
  add_foreign_key "sections", "courses"
end
