class RoomBlocksController < ApplicationController
    def create
        room = Room.find(params[:room_id])
        time_slot = TimeSlot.find(params[:time_slot_id])
      
        # Create or update the block for the current time slot
        block = RoomBlock.find_or_create_by(room: room, time_slot: time_slot)
        block.update(is_blocked: true)
      
        # Block related time slots
        time_slot.related_time_slots.each do |related_time_slot|
          related_block = RoomBlock.find_or_create_by(room: room, time_slot: related_time_slot)
          related_block.update(is_blocked: true)
        end
      
        redirect_to schedule_time_slots_path(params[:schedule_id]), notice: "Room #{room.building_code} #{room.room_number} blocked for #{time_slot.start_time} - #{time_slot.end_time}"
      end

      def destroy
        block = RoomBlock.find(params[:id])
        room = block.room
        time_slot = block.time_slot
      
        # Unblock the current time slot
        block.destroy if block
      
        # Unblock related time slots
        time_slot.related_time_slots.each do |related_time_slot|
          related_block = RoomBlock.find_by(room: room, time_slot: related_time_slot)
          related_block&.destroy # Destroy related blocks if they exist
        end
      
        redirect_to schedule_time_slots_path(params[:schedule_id]), notice: "Room #{room.building_code} #{room.room_number} unblocked for #{time_slot.start_time} - #{time_slot.end_time}"
      end
    end
