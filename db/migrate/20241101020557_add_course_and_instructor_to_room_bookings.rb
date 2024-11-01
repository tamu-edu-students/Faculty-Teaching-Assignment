# frozen_string_literal: true

class AddCourseAndInstructorToRoomBookings < ActiveRecord::Migration[7.2]
  def change
    add_reference :room_bookings, :course, null: false, foreign_key: true
    add_reference :room_bookings, :instructor, null: false, foreign_key: true
  end
end
