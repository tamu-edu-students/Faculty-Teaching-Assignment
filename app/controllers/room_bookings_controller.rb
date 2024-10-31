# Room Bookings Controller
class RoomBookingsController < ApplicationController
  before_action :set_schedule

  def index
    @rooms = @schedule.rooms.where(is_active: true).where.not(building_code: 'ONLINE')
    @tabs = TimeSlot.distinct.pluck(:day)
    @active_tab = params[:active_tab] || @tabs[0]
    @time_slots = TimeSlot.where(day: @active_tab).order(:start_time)

    @room_bookings = RoomBooking.joins(:room, :time_slot)
                                .where(rooms: { schedule_id: @schedule.id }, time_slots: { day: @active_tab })
    @bookings_matrix = @room_bookings.each_with_object({}) do |booking, hash|
      hash[[booking.room_id, booking.time_slot_id]] = booking
    end
  end

  # RoomBookingsController
# RoomBookingsController
# RoomBookingsController
def toggle_availability
  room_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: params[:time_slot_id])
  new_status = !room_booking.is_available
  room_booking.update(is_available: new_status)

  # Calculate relevant days based on the current active tab
  relevant_days = calculate_relevant_days(params[:active_tab])

  # Manually construct the overlap conditions since SQLite lacks the OVERLAPS function
  related_time_slots = TimeSlot.where(day: relevant_days)
                               .where("start_time < ? AND end_time > ?", 
                                      room_booking.time_slot.end_time, 
                                      room_booking.time_slot.start_time)

  # Update RoomBookings to reflect the new status across relevant overlapping time slots and days
  RoomBooking.where(room_id: params[:room_id], time_slot: related_time_slots)
             .update_all(is_available: new_status)

  # Redirect back to the room bookings page with the active tab
  redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
end




  private

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def calculate_relevant_days(current_tab)
    case current_tab
    when 'MWF'
      %w[MWF MW F]
    when 'MW'
      %w[MWF MW]
    when 'F'
      %w[MWF F]
    else
      [current_tab] # Only affects TR or any isolated day
    end
  end
end
