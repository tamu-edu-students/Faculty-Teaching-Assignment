# frozen_string_literal: true

# Course model
class Course < ApplicationRecord
  belongs_to :schedule
  has_many :sections
  has_many :instructor_preferences
end
