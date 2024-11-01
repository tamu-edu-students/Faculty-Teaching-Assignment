# frozen_string_literal: true

# Section model
class Section < ApplicationRecord
  belongs_to :course
  has_one :room_booking
end
