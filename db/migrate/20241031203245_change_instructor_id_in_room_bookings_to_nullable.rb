# frozen_string_literal: true

class ChangeInstructorIdInRoomBookingsToNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :room_bookings, :instructor_id, true
  end
end
