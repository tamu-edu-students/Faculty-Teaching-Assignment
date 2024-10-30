# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  has_many :room_bookings, dependent: :destroy
  has_many :room_blocks
  has_many :blocked_rooms, through: :room_blocks, source: :room

  validates :day, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :slot_type, presence: true
  validate :end_time_after_start_time

  def related_time_slots
    TimeSlot.where(start_time: self.start_time, end_time: self.end_time)
            .where.not(id: self.id)
  end
  
  private

  def end_time_after_start_time
    return unless end_time.present? && start_time.present? && end_time <= start_time

    errors.add(:end_time, 'must be after the start time')
  end

  
end
