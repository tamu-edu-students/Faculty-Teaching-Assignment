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

ActiveRecord::Schema[7.2].define(version: 2024_10_17_221341) do
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
    t.integer "schedule_id", null: false
    t.index ["schedule_id"], name: "index_rooms_on_schedule_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "schedule_name"
    t.string "semester_name"
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

  add_foreign_key "rooms", "schedules"
end
