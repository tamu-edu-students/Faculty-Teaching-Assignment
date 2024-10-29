# frozen_string_literal: true

# Controller for uploaded time slots
class TimeSlotsController < ApplicationController
  def filter
    @schedule = Schedule.find(params[:schedule_id])

    @time_slots = TimeSlot.all
    @time_slots = @time_slots.where(day: params[:day]) if params[:day].present?
    @time_slots = @time_slots.where(slot_type: params[:slot_type]) if params[:slot_type].present?

    redirect_to schedule_time_slots_path(@schedule, day: params[:day], slot_type: params[:slot_type])
  end

  def index
    @time_slots = TimeSlot.all
    @time_slots = @time_slots.where(day: params[:day]) if params[:day].present?
    @time_slots = @time_slots.where(slot_type: params[:slot_type]) if params[:slot_type].present?

    @schedule = (Schedule.find(params[:schedule_id]) if params[:schedule_id].present?)
  end
end
