# frozen_string_literal: true

# The User model represents users in the application.
class User < ApplicationRecord
  validates :email, presence: true
  has_many :schedules, dependent: :destroy
end
