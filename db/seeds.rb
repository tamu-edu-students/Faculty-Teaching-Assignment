# frozen_string_literal: true

require 'set'
require 'json'

ROOMS_DATA_PATH = 'db/rooms.json'

def seed_room_data
    file = File.open(ROOMS_DATA_PATH).read
    json_room_data = JSON.parse file
    
    # Clear out the Room table
    Room.delete_all
    puts "Cleared the Room database."

    props = Set.new
    usage_type_map = {
        "lab": 0,
        "learning_studio": 0,
        "lecture_hall": 0,
        "others": 0
    }

    active_rooms = 0

    json_room_data.each do |room| 
        room["is_lecture_hall"] = false 
        room["is_learning_studio"] = false
        room["is_lab"] = false
        
        if room["usage_types"] != nil
            room["usage_types"].each do |type|
                if type == 1
                    room["is_lecture_hall"] = true
                    usage_type_map[:lecture_hall] += 1
                elsif type == 2
                    room["is_learning_studio"] = true
                    usage_type_map[:learning_studio] += 1
                elsif type == 3
                    room["is_lab"] = true
                    usage_type_map[:lab] += 1
                end
            end
        elsif room["is_active"]
            usage_type_map[:others] += 1
        end

        Room.create!(
            campus: room['campus'],
            building_code: room['building_code'],
            room_number: room['room_number'],
            capacity: room['capacity'],
            is_lecture_hall: room['is_lecture_hall'],
            is_learning_studio: room['is_learning_studio'],
            is_lab: room['is_lab'],
            is_active: room['is_active'],
            comments: room['comments']
        )

        if room['is_active'] == true
            active_rooms += 1
        end
    end 

    puts "Seeded #{json_room_data.length} rooms into the database"
    puts "Active Rooms : #{active_rooms}"
    usage_type_map.each do |k, v|
        puts "#{k} : #{v}"
    end
end

seed_room_data()