# frozen_string_literal: true

# Model for Instructor preferences
class InstructorPreference < ApplicationRecord
  belongs_to :instructor
end
