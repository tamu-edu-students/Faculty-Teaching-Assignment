# frozen_string_literal: true

# Room Model
class Room < ApplicationRecord
  belongs_to :schedule
  has_many :room_bookings, dependent: :destroy
  has_many :room_blocks
  has_many :blocked_time_slots, through: :room_blocks, source: :time_slot
  enum :campus, { NONE: 0, CS: 1, GV: 2 }

  validates :building_code, presence: true
  validates :room_number, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :is_lecture_hall, :is_learning_studio, :is_lab, inclusion: { in: [true, false] }
end
