# frozen_string_literal: true

# Course model
class Course < ApplicationRecord
  belongs_to :schedule
  has_many :room_bookings, dependent: :destroy
  has_many :instructor_preferences, dependent: :destroy
end
