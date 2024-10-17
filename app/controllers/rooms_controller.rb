class RoomsController < ApplicationController
  helper_method :sort_column, :sort_direction
  
  def index
    if params[:active_rooms] == "true"
      @rooms = Room.where(is_active: true)
      @active_filter = true
    else
      @rooms = Room.all
      @active_filter = false
    end

    @rooms = @rooms.order("#{sort_column} #{sort_direction}")
  end

  private
  # Define the allowed sorting columns
  def sort_column
    Room.column_names.include?(params[:sort]) ? params[:sort] : "building_code"
  end

  # Define the sorting direction (ascending or descending)
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
