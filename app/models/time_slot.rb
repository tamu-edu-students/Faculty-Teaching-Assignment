# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  has_many :room_bookings, dependent: :destroy
  
  validates :day, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :slot_type, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return unless end_time.present? && start_time.present? && end_time <= start_time

    errors.add(:end_time, 'must be after the start time')
  end
end
