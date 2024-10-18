# frozen_string_literal: true

# Instructor model
class Instructor < ApplicationRecord
  belongs_to :schedule
end
