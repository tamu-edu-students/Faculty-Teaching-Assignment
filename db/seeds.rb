# frozen_string_literal: true

require 'json'

ROOMS_DATA_PATH = 'db/rooms.json'

def seed_room_data
    file = File.open(ROOMS_DATA_PATH).read
    json_room_data = JSON.parse file
    
    puts json_room_data
end