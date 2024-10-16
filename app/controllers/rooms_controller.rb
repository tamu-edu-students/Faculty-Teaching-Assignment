class RoomsController < ApplicationController
  def index
    if params[:active_rooms] == "true"
      @rooms = Room.where(is_active: true)
    else
      @rooms = Room.all
    end
  end
end
