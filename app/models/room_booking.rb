class RoomBooking < ApplicationRecord
  belongs_to :room
  belongs_to :time_slot
end
