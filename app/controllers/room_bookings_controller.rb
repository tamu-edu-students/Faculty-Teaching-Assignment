# frozen_string_literal: true

class RoomBookingsController < ApplicationController
  before_action :set_schedule

  def index
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
    ).where(rooms: { schedule_id: @schedule.id }, time_slots: { day: @active_tab })
    @block_due_to_parallel_booking = {}
    @bookings_matrix = @room_bookings.each_with_object({}) do |booking, hash|
      hash[[booking.room_id, booking.time_slot_id]] = booking
      @block_due_to_parallel_booking[[booking.room_id, booking.time_slot_id]] = false
      overlapping_time_slots = find_overlapping_time_slots(booking.time_slot)
      overlapping_time_slots.each do |overlapping_slot|
        overlapping_booking = RoomBooking.find_or_initialize_by(room_id: booking.room_id, time_slot_id: overlapping_slot.id)

        next unless section_alloted?(overlapping_booking)

        unless booking.id == overlapping_booking.id
          @block_due_to_parallel_booking[[booking.room_id, booking.time_slot_id]] =
            overlapping_booking.time_slot.day
        end
        break
      end
    end
  end

  def toggle_availability
    room_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: params[:time_slot_id])
    room_booking.is_available
    room_booking.update(is_available: params[:is_available])

    overlapping_time_slots = find_overlapping_time_slots(room_booking.time_slot)
    overlapping_time_slots.each do |overlapping_slot|
      overlapping_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: overlapping_slot.id)
      overlapping_booking.update(is_available: params[:is_available])
    end

    redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
  end

  def create
    @schedule = Schedule.find(params[:schedule_id])
    room_booking = RoomBooking.find_or_initialize_by(room_id: room_booking_params[:room_id], time_slot_id: room_booking_params[:time_slot_id])

    if room_booking.is_locked
      flash[:alert] = 'Locked Room Bookings Cannot be updated.'
      redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
      return
    end

    unless room_booking.is_available
      flash[:alert] = 'Cannot assign to a blocked room.'
      redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
      return
    end

    respond_to do |format|
      if room_booking.save
        room_booking.update(section_id: room_booking_params[:section_id])

        overlapping_time_slots = find_overlapping_time_slots(room_booking.time_slot)

        overlapping_time_slots.each do |overlapping_slot|
          overlapping_booking = RoomBooking.find_or_initialize_by(room_id: room_booking_params[:room_id], time_slot_id: overlapping_slot.id)
          overlapping_booking.update(is_available: false) unless overlapping_booking.id == room_booking.id
        end
        format.html do
          redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab]), notice: 'Room Booking was successfully created.'
        end
        format.json { render :index, status: :created }
      else
        flash[:alert] = 'Failed to create room booking'
        render json: { error: 'Failed to create room booking', details: room_booking.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @schedule = Schedule.find(params[:schedule_id])
    @room_booking = RoomBooking.find_by(id: params[:id])

    if @room_booking
      if @room_booking.is_locked
        flash[:alert] = 'Locked Room Bookings Cannot be deleted'
        redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
        return
      end
      overlapping_time_slots = find_overlapping_time_slots(@room_booking.time_slot)
      @room_booking.destroy

      overlapping_time_slots.each do |overlapping_slot|
        overlapping_booking = RoomBooking.find_or_initialize_by(room_id: @room_booking.room_id, time_slot_id: overlapping_slot.id)
        overlapping_booking.update(is_available: true) unless overlapping_booking.id == @room_booking.id
      end
      flash[:notice] = 'Room booking deleted successfully.'
    else
      flash[:alert] = 'Room booking not found.'
    end

    redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
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
    # Generate CSV data
    csv_data = generate_csv_data

    # Send the CSV file as a response
    respond_to do |format|
      format.csv { send_data csv_data, filename: 'room_bookings.csv', type: 'text/csv' }
      format.any { send_data csv_data, filename: 'room_bookings.csv', type: 'text/csv' }
    end
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def find_overlapping_time_slots(time_slot)
    start_time = Time.strptime(time_slot.start_time, '%H:%M')
    end_time = Time.strptime(time_slot.end_time, '%H:%M')

    relevant_days = calculate_relevant_days(time_slot.day)

    TimeSlot.where(day: relevant_days).select do |slot|
      slot_start_time = Time.strptime(slot.start_time, '%H:%M')
      slot_end_time = Time.strptime(slot.end_time, '%H:%M')
      slot_start_time < end_time && slot_end_time > start_time
    end
  end

  def calculate_relevant_days(current_day)
    case current_day
    when 'MWF'
      %w[MWF MW F]
    when 'MW'
      %w[MWF MW]
    when 'F'
      %w[MWF F]
    else
      [current_day]
    end
  end

  def fetch_rooms(schedule_id)
    Room.where(schedule_id:, is_active: true)
        .where.not(building_code: 'ONLINE')
        .order(:room_number)
  end

  def fetch_unique_days
    TimeSlot.distinct.pluck(:day)
  end

  def generate_csv_data
    schedule_id = params[:schedule_id]
    rooms = fetch_rooms(schedule_id)
    unique_days = fetch_unique_days

    CSV.generate(headers: true) do |csv|
      unique_days.each do |day|
        add_day_section_to_csv(csv, day, rooms)
      end
    end
  end

  def add_day_section_to_csv(csv, day, rooms)
    csv << day_header_row(day, rooms)
    fetch_time_slots(day).each do |time_slot|
      csv << time_slot_row(time_slot, rooms)
    end
    csv << [] # Add an empty row to separate each day's section
  end

  def day_header_row(day, rooms)
    [day] + rooms.map { |room| "#{room.building_code} #{room.room_number} (Seats: #{room.capacity})" }
  end

  def fetch_time_slots(day)
    TimeSlot.where(day:).order(:start_time)
  end

  def time_slot_row(time_slot, rooms)
    row = [format_time_slot(time_slot)]
    room_bookings = fetch_room_bookings(time_slot, rooms)

    rooms.each do |room|
      row << booking_info(room_bookings[room.id])
    end

    row
  end

  def fetch_room_bookings(time_slot, rooms)
    RoomBooking.where(time_slot:, room: rooms)
               .includes(room: {}, section: :course, instructor: {})
               .index_by { |booking| booking.room.id }
  end

  def booking_info(booking)
    return '' unless booking

    course_number = fetch_course_number(booking)
    section_number = fetch_section_number(booking)
    instructor_name = fetch_instructor_name(booking)

    "#{course_number} - #{section_number} - #{instructor_name}".strip
  end

  def fetch_course_number(booking)
    booking.section&.course&.course_number || 'N/A'
  end

  def fetch_section_number(booking)
    booking.section&.section_number || 'N/A'
  end

  def fetch_instructor_name(booking)
    if booking.instructor
      "#{booking.instructor.first_name} #{booking.instructor.last_name}"
    else
      'N/A'
    end
  end

  def format_time_slot(time_slot)
    "#{time_slot.start_time} - #{time_slot.end_time}"
  end

  def section_alloted?(overlapping_booking)
    overlapping_booking.section_id.present?
  end

  def room_booking_params
    params.require(:room_booking).permit(:room_id, :time_slot_id, :is_available, :is_lab, :instructor_id, :section_id)
  end
end
