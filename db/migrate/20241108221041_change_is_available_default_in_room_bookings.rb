# frozen_string_literal: true

class ChangeIsAvailableDefaultInRoomBookings < ActiveRecord::Migration[7.2]
  def change
    change_column_default :room_bookings, :is_available, from: nil, to: true
  end
end
