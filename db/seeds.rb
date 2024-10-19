# frozen_string_literal: true

require 'set'
require 'json'
require 'csv'

ROOMS_DATA_PATH = 'db/rooms.json'

def process_room_data(room)
  room_usage_types(room)
  create_room(room)
end

def room_usage_types(room)
  room['is_lecture_hall'] = room['usage_types']&.include?(1) || false
  room['is_learning_studio'] = room['usage_types']&.include?(2) || false
  room['is_lab'] = room['usage_types']&.include?(3) || false
end

def create_room(room)
  Room.create!(
    campus: room['campus'],
    building_code: room['building_code'],
    room_number: room['room_number'],
    capacity: room['capacity'],
    is_lecture_hall: room['is_lecture_hall'],
    is_learning_studio: room['is_learning_studio'],
    is_lab: room['is_lab'],
    is_active: room['is_active'],
    comments: room['comments'],
    schedule_id: 1
  )
end

def parse_room_data(json_room_data)
  active_rooms = 0

  json_room_data.each do |room|
    process_room_data(room)
    active_rooms += 1 if room['is_active']
  end

  active_rooms
end

def seed_room_data
  file = File.read(ROOMS_DATA_PATH)
  json_room_data = JSON.parse file

  # Clear out the Room table
  Room.delete_all
  Rails.logger.debug 'Cleared the Room database.'

  active_rooms = parse_room_data(json_room_data)

  Rails.logger.debug { "Seeded #{json_room_data.length} rooms into the database" }
  Rails.logger.debug { "Active Rooms : #{active_rooms}" }
end

# def seed_course_data
#   CSV.foreach(Rails.root.join('db/courses.csv'), headers: true) do |row|
#     Course.create!(
#       course_number: row['course number'].to_i,  # Ensure this is an integer
#       title: row['title'],
#       description: row['description'],
#       subject: row['subject'],  # Assuming subject is present in the CSV
#       lec_hours: row['lecture hours'].to_i,  # Convert to integer
#       lab_hours: row['lab hours'].to_i  # Convert to integer
#     )
#   end
# end

seed_room_data
seed_course_data
