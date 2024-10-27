class RoomBookingsController < ApplicationController
    def index
        schedule_id = params[:schedule_id]
        @schedule = Schedule.find(params[:schedule_id])
        @rooms = @schedule.rooms
        @time_slots = TimeSlot.all

        # Fetch room bookings only for the specified schedule
        @room_bookings = RoomBooking.joins(:room, :time_slot)
                                    .where(rooms: { schedule_id: schedule_id })
    end
end
  