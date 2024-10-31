# frozen_string_literal: true

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

  before_action :set_schedule

  def toggle_availability
    room_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: params[:time_slot_id])
    new_status = !room_booking.is_available
    room_booking.update(is_available: new_status)

    overlapping_time_slots = find_overlapping_time_slots(room_booking.time_slot)
    overlapping_time_slots.each do |overlapping_slot|
      overlapping_booking = RoomBooking.find_or_initialize_by(room_id: params[:room_id], time_slot_id: overlapping_slot.id)
      overlapping_booking.update(is_available: new_status)
    end

    redirect_to schedule_room_bookings_path(@schedule, active_tab: params[:active_tab])
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def find_overlapping_time_slots(time_slot)
    relevant_days = calculate_relevant_days(time_slot.day)

    TimeSlot.where(day: relevant_days)
            .where('start_time < ? AND end_time > ?', time_slot.end_time, time_slot.start_time)
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
end
