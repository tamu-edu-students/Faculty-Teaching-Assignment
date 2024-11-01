# frozen_string_literal: true

# The model for the Schedule class represents the schedules
class Schedule < ApplicationRecord
  has_many :rooms, dependent: :destroy
  has_many :instructors, dependent: :destroy
  has_many :courses, dependent: :destroy
  validates :schedule_name, :semester_name, presence: true
end
