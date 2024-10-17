# frozen_string_literal: true

# Controller for rooms
class RoomsController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @rooms = Room.all

    if params[:active_rooms] == 'true'
      @rooms = Room.where(is_active: true)
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
end
