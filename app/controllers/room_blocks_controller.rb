class RoomBlocksController < ApplicationController
    def create
        room = Room.find(params[:room_id])
        time_slot = TimeSlot.find(params[:time_slot_id])
      
        # Block the selected time slot
        block = RoomBlock.find_or_create_by(room: room, time_slot: time_slot)
        block.update(is_blocked: true)
      
        # Block overlapping time slots only for relevant days
        overlapping_time_slots = find_overlapping_time_slots(room, time_slot)
        overlapping_time_slots.each do |overlapping_slot|
          RoomBlock.find_or_create_by(room: room, time_slot: overlapping_slot).update(is_blocked: true)
        end
      
        redirect_back(fallback_location: schedule_time_slots_path(params[:schedule_id]))
      end
      
    
      def destroy
        block = RoomBlock.find(params[:id])
        room = block.room
        time_slot = block.time_slot
      
        if block
          block.update(is_blocked: false) # Mark as not blocked
          block.destroy # Remove the block entry
        end
      
        # Unblock all related time slots for the same room across relevant days
        related_time_slots = find_related_time_slots_across_tabs(room, time_slot)
        related_time_slots.each do |related_slot|
          related_block = RoomBlock.find_by(room: room, time_slot: related_slot)
          related_block&.update(is_blocked: false) # Ensure to mark as not blocked
          related_block&.destroy # Remove related blocks if they exist
        end
      
        redirect_back(fallback_location: schedule_time_slots_path(params[:schedule_id]))
      end
    
    private
    
    # Finds overlapping time slots for the same room and time slot across all tabs
    def find_overlapping_time_slots(room, time_slot)
        TimeSlot.where.not(id: time_slot.id).select do |other_slot|
          time_slots_overlap?(time_slot, other_slot) && relevant_day?(time_slot, other_slot)
        end
      end
      
      # Checks if two time slots overlap based on their time range
      def time_slots_overlap?(slot1, slot2)
        slot1.start_time < slot2.end_time && slot2.start_time < slot1.end_time
      end
    
    # Finds related time slots across all tabs for the same room and time slot
    def find_related_time_slots_across_tabs(room, time_slot)
      TimeSlot.where(id: time_slot.related_time_slots.pluck(:id))
    end
    
  
    # Check if the time slots are on relevant days (MWF or TR)
    def relevant_day?(time_slot1, time_slot2)
        time_slot1.day.chars.any? { |day| time_slot2.day.include?(day) }
      end
  end
  