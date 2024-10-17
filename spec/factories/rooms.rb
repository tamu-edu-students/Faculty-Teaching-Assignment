# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    campus { 'CS' }
    building_code { 'B101' }
    room_number { '101' }
    capacity { 50 }
    is_active { true }
    is_lab { true }
    is_learning_studio { false }
    is_lecture_hall { false }
    comments { 'A large lecture hall.' }
  end
end
