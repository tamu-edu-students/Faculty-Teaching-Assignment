# frozen_string_literal: true

# Room Bookings Controller
class RoomBookingsController < ApplicationController
  def index
    schedule_id = params[:schedule_id]
    @schedule = Schedule.find(params[:schedule_id])
    @rooms = @schedule.rooms.where(is_active: true).where.not(building_code: 'ONLINE')
    @tabs = TimeSlot.distinct.pluck(:day)
    @active_tab = params[:active_tab] || session[:active_rb_tab] || @tabs[0]
    session[:active_rb_tab] = @active_tab
    @time_slots = TimeSlot.where(time_slots: { day: @active_tab }).to_a
    @time_slots.sort_by! { |ts| Time.parse(ts.start_time) }
    @instructors = @schedule.instructors

    # Fetch room bookings only for the specified schedule
    @room_bookings = RoomBooking.includes(
      room: {},
      section: [:course],
      time_slot: {},
      instructor: {}
    ).where(rooms: { schedule_id: }, time_slots: { day: @active_tab })

    # Organize room bookings in a hash with room_id and time_slot_id as keys
    @bookings_matrix = @room_bookings.each_with_object({}) do |booking, hash|
      hash[[booking.room_id, booking.time_slot_id]] = booking
    end
  end

  def create
    room_booking = RoomBooking.new(room_booking_params)
    @schedule = Schedule.find(params[:schedule_id])

    respond_to do |format|
      if room_booking.save
        format.html { redirect_to schedule_room_bookings_path(@schedule), notice: 'Room Booking was successfully created.' }
        format.json { render :index, status: :created }
      else
        flash[:alert] = 'Did not work'
        render json: { error: 'Failed to create room booking', details: room_booking.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @schedule = Schedule.find(params[:schedule_id])
    @room_booking = RoomBooking.find_by(id: params[:id])

    if @room_booking
      @room_booking.destroy
      flash[:notice] = 'Room booking deleted successfully.'
    else
      flash[:alert] = 'Room booking not found.'
    end

    redirect_to schedule_room_bookings_path(@schedule) # Redirect to the list of room bookings or another appropriate page
  end

  def toggle_lock
    @room_booking = RoomBooking.find(params[:id])

    # Toggle the `is_locked` value
    @room_booking.update(is_locked: !@room_booking.is_locked)

    # Optionally add a notice or alert to show success or failure
    flash[:notice] = 'Room booking lock status updated successfully.'

    # Redirect to the previous page or another relevant page
    redirect_back(fallback_location: room_bookings_path)
  end

  def update_instructor
    @booking = RoomBooking.find(params[:id])

    if @booking.update(instructor_id: params[:room_booking][:instructor_id])
      flash[:notice] = 'Instructor updated successfully.'
    else
      flash[:alert] = 'Failed to update instructor.'
    end

    # Redirect to the previous page or another relevant page
    redirect_back(fallback_location: room_bookings_path)
  end

  def export_csv
    # Get the schedule ID from the parameters
    schedule_id = params[:schedule_id]

    # Fetch rooms based on the schedule and active status, excluding online rooms
    rooms = Room.where(schedule_id: schedule_id, is_active: true).where.not(building_code: 'ONLINE').order(:room_number)

    # Get all unique days from the time slots table
    unique_days = TimeSlot.distinct.pluck(:day)

    # Generate CSV data
    csv_data = CSV.generate(headers: true) do |csv|
      # Iterate over each unique day
      unique_days.each do |day|
        # Add a section header for each day
        # csv << ["Day: #{day}"] # Day section title

        # Header row with the day and room names + capacities
        csv << [day] + rooms.map { |room| "#{room.building_code} #{room.room_number} (Seats: #{room.capacity})" }

        # Fetch time slots for the current day
        time_slots = TimeSlot.where(day: day).sort_by { |ts| Time.parse(ts.start_time) }

        # Iterate through each time slot
        time_slots.each do |time_slot|
          # Start the row with the formatted time slot
          row = [format_time_slot(time_slot)]

          # Fetch bookings for each room in the current time slot
          room_bookings = RoomBooking.where(time_slot: time_slot, room: rooms)
                                     .includes(room: {}, section: :course, instructor: {})
                                     .index_by { |booking| booking.room.id }

          # Populate row with course number, section, and instructor data for each room
          rooms.each do |room|
            booking = room_bookings[room.id]
            if booking
              course_number = booking.section&.course&.course_number || "N/A"
              section_number = booking.section&.section_number || "N/A"
              instructor_name = booking.instructor ? "#{booking.instructor.first_name} #{booking.instructor.last_name}" : "N/A"
              row << "#{course_number} - #{section_number} - #{instructor_name}".strip
            else
              row << "" # No booking for this room at this time slot
            end
          end

          csv << row # Add row to CSV
        end

        # Add an empty row to separate each day's section in the CSV
        csv << []
      end
    end

    # Send the CSV file as a response
    respond_to do |format|
      format.csv { send_data csv_data, filename: "room_bookings.csv", type: 'text/csv' }
      format.any { send_data csv_data, filename: "room_bookings.csv", type: 'text/csv' }
    end
  end
  
  private

  def format_time_slot(time_slot)
    "#{time_slot.start_time} - #{time_slot.end_time}"
  end

  private

  def room_booking_params
    params.require(:room_booking).permit(:room_id, :time_slot_id, :is_available, :is_lab, :instructor_id, :section_id)
  end
end
