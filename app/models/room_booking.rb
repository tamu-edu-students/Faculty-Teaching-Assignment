# frozen_string_literal: true

class RoomBooking < ApplicationRecord
  belongs_to :room
  belongs_to :time_slot
  belongs_to :section, optional: true
  belongs_to :instructor, optional: true
  validates :course, presence: true
end
