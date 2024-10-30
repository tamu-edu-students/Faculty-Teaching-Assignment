# frozen_string_literal: true

# Room Bookings Controller
class RoomBookingsController < ApplicationController
  def index
    schedule_id = params[:schedule_id]
    @schedule = Schedule.find(params[:schedule_id])
    @rooms = @schedule.rooms.where(is_active: true).where.not(building_code: 'ONLINE')
    @tabs = TimeSlot.distinct.pluck(:day)
    @active_tab = params[:active_tab] || @tabs[0]
    @time_slots = TimeSlot.where(time_slots: { day: @active_tab }).to_a
    @time_slots.sort_by! { |ts| Time.parse(ts.start_time) }

    # Fetch room bookings only for the specified schedule
    @room_bookings = RoomBooking.joins(:room, :time_slot)
                                .where(rooms: { schedule_id: schedule_id }, time_slots: { day: @active_tab })

    # Organize room bookings in a hash with room_id and time_slot_id as keys
    @bookings_matrix = @room_bookings.each_with_object({}) do |booking, hash|
      hash[[booking.room_id, booking.time_slot_id]] = booking
    end
  end
end
