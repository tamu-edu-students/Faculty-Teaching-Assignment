# frozen_string_literal: true

class TimeSlotsController < ApplicationController
  def index
    @time_slots = TimeSlot.all
    @time_slots = @time_slots.where(day: params[:day]) if params[:day].present?
    @time_slots = @time_slots.where(slot_type: params[:slot_type]) if params[:slot_type].present?
  end
end
