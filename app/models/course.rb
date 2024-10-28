# frozen_string_literal: true

class Course < ApplicationRecord
  belongs_to :schedule
  has_many :sections
end
