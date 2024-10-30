class RoomBlocksController < ApplicationController
    def create
        room = Room.find(params[:room_id])
        time_slot = TimeSlot.find(params[:time_slot_id])
        
        # Create or update the block for the selected time slot
        block = RoomBlock.find_or_create_by(room: room, time_slot: time_slot)
        block.update(is_blocked: true)
        
        # Find and block overlapping time slots
        overlapping_time_slots = find_overlapping_time_slots(room, time_slot)
        overlapping_time_slots.each do |overlapping_slot|
          RoomBlock.find_or_create_by(room: room, time_slot: overlapping_slot).update(is_blocked: true)
        end
        
        # Redirect back to the same page
        redirect_back(fallback_location: schedule_time_slots_path(params[:schedule_id]))
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
      
        redirect_back(fallback_location: schedule_time_slots_path(params[:schedule_id]))
      end
    end

    private

    # This method finds overlapping time slots based on start and end times
    private

# This method finds overlapping time slots based on start and end times
def find_overlapping_time_slots(room, time_slot)
  # Get all time slots for the same room
  overlapping_time_slots = TimeSlot.where.not(id: time_slot.id).select do |other_slot|
    time_slots_overlap?(time_slot, other_slot)
  end

  # Return the overlapping time slots associated with the same room
  overlapping_time_slots
end

# Check if two time slots overlap based on their time range
def time_slots_overlap?(slot1, slot2)
  # Check if the time ranges overlap
  slot1.start_time < slot2.end_time && slot2.start_time < slot1.end_time
end

