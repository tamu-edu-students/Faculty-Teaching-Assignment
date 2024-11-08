# frozen_string_literal: true

class RoomBookingsController < ApplicationController
  before_action :set_schedule

  def index
    # @schedule = Schedule.find(params[:schedule_id])
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

    # Organize room bookings in a hash with room_id and time_slot_id as keys
    @bookings_matrix = @room_bookings.each_with_object({}) do |booking, hash|
      hash[[booking.room_id, booking.time_slot_id]] = booking
    end
  end

  def toggle_availability
    room_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: params[:time_slot_id])
    new_status = !room_booking.is_available
    room_booking.update(is_available: params[:is_available])

    overlapping_time_slots = find_overlapping_time_slots(room_booking.time_slot)
    overlapping_time_slots.each do |overlapping_slot|
      overlapping_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: overlapping_slot.id)
      overlapping_booking.update(is_available: params[:is_available])
    end

    flash[:notice] = overlapping_time_slots

    redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
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

  private

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def find_overlapping_time_slots(time_slot)
    start_time = Time.strptime(time_slot.start_time, "%H:%M")
    end_time = Time.strptime(time_slot.end_time, "%H:%M")

    relevant_days = calculate_relevant_days(time_slot.day)

    TimeSlot.where(day: relevant_days).select do |slot|
      slot_start_time = Time.strptime(slot.start_time, "%H:%M")
      slot_end_time = Time.strptime(slot.end_time, "%H:%M")
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
  
  def room_booking_params
    params.require(:room_booking).permit(:room_id, :time_slot_id, :is_available, :is_lab, :instructor_id, :section_id)
  end
end
