# frozen_string_literal: true

# Instructor model
class Instructor < ApplicationRecord
  belongs_to :schedule
  has_many :instructor_preferences, dependent: :destroy
  has_many :room_bookings
  
end
