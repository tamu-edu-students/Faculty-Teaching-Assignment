class RoomsController < ApplicationController
  def index
    @rooms = Room.where(is_active: true)
  end
end
