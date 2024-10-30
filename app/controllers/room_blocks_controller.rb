class RoomBlocksController < ApplicationController
    def create
        room = Room.find(params[:room_id])
        time_slot = TimeSlot.find(params[:time_slot_id])

        block = RoomBlock.find_or_create_by(room: room, time_slot: time_slot)
        block.update(is_blocked: true)

        redirect_to schedule_time_slots_path(params[:schedule_id]), notice: "Room #{room.building_code} #{room.room_number} blocked for #{time_slot.start_time} - #{time_slot.end_time}"
    end

    def destroy
        block = RoomBlock.find(params[:id]) # Find the block by the ID passed in the route
        block.destroy if block # Destroy the block if it exists
    
        redirect_to schedule_time_slots_path(params[:schedule_id]), notice: "Room #{block.room.building_code} #{block.room.room_number} unblocked for #{block.time_slot.start_time} - #{block.time_slot.end_time}"
    end
    
end
