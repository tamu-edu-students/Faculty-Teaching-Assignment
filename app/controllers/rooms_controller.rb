# frozen_string_literal: true

# Controller for rooms
class RoomsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_schedule, only: [:index]

  def index
    @schedule = current_user.schedules.find(params[:schedule_id])
    @rooms = @schedule.rooms
    if params[:active_rooms] == 'true'
      @rooms = @rooms.where(is_active: true)
      @active_filter = true
    else
      @active_filter = false
    end

    direction = params[:direction] == 'desc' ? 'desc' : 'asc'
    @rooms = @rooms.order("#{sort_column} #{direction}")
  end

  private

  # Define the allowed sorting columns
  def sort_column
    Room.column_names.include?(params[:sort]) ? params[:sort] : 'building_code'
  end

  # Define the sorting direction (ascending or descending)
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # Set the schedule correctly
  def set_schedule
    @schedule = current_user.schedules.find(params[:schedule_id]) if params[:schedule_id]
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Schedule not found.'
    redirect_to schedules_path
  end
end
