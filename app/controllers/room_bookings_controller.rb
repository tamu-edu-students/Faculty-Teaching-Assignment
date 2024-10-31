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
    @instructors = @schedule.instructors

    # Fetch room bookings only for the specified schedule
    @room_bookings = RoomBooking.includes(
                        room: {},
                        section: [:course],
                        time_slot: {},
                        instructor: {}
                      ).where(rooms: { schedule_id: schedule_id }, time_slots: { day: @active_tab })
                      

    # Organize room bookings in a hash with room_id and time_slot_id as keys
    @bookings_matrix = @room_bookings.each_with_object({}) do |booking, hash|
      hash[[booking.room_id, booking.time_slot_id]] = booking
    end
  end


  def create
    room_booking = RoomBooking.new(room_booking_params)
    @schedule = Schedule.find(params[:schedule_id]);

    respond_to do |format|
      if room_booking.save
        format.html { redirect_to schedule_room_bookings_path(@schedule), notice: "Movie was successfully created." }
        format.json { render :index, status: :created }
      else
        render json: { error: 'Failed to create room booking', details: room_booking.errors.full_messages }, status: :unprocessable_entity
        flash[:alert] = "Did not work"
      end
    end
  end

  private

  def room_booking_params
    params.require(:room_booking).permit(:room_id, :time_slot_id, :is_available, :is_lab, :instructor_id, :section_id)
  end
end
