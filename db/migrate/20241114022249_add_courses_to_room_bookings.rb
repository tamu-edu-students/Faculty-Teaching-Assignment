# frozen_string_literal: true

class AddCoursesToRoomBookings < ActiveRecord::Migration[7.2]
  def change
    add_reference :room_bookings, :course, foreign_key: true unless column_exists?(:room_bookings, :course_id)
  end
end
