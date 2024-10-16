# frozen_string_literal: true

class Schedule < ApplicationRecord
  validates :schedule_name, :semester_name, presence: true
end
