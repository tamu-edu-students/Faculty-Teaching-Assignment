# frozen_string_literal: true

class AddSectionToRoomBookings < ActiveRecord::Migration[7.2]
  def change
    add_reference :room_bookings, :section, foreign_key: true
  end
end
