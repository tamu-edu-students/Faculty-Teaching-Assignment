# frozen_string_literal: true

# The model for the Schedule class represents the schedules
class Schedule < ApplicationRecord
  has_many :rooms
  has_many :instructors
  has_many :courses
  validates :schedule_name, :semester_name, presence: true
end
