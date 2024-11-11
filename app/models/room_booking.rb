# frozen_string_literal: true

class RoomBooking < ApplicationRecord
  belongs_to :room
  belongs_to :time_slot
  belongs_to :section
  belongs_to :instructor, optional: true

  
end
