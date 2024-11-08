# frozen_string_literal: true

FactoryBot.define do
  factory :schedule do
    schedule_name { 'Test Schedule' }
    semester_name { 'Fall 2024' }
  end

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
    association :schedule
  end

  factory :instructor do
    id_number { rand(1000..9999) }
    first_name { 'John' } # Default first name
    last_name { 'Doe' }  # Default last name
    middle_name { 'A' }  # Default middle name (optional)
    email { 'abc@gmail.com' } # Generate a random email
    before_9 { [true, false].sample } # Random boolean
    after_3 { [true, false].sample } # Random boolean
    beaware_of { 'Some notes or warnings.' } # Default text
    association :schedule # Associate with a Schedule, assuming you have a Schedule factory as well
  end

  factory :room_booking do
    association :room
    association :time_slot
    is_available { true }
    is_lab { [true, false].sample }
    is_locked { false }
    association :instructor
    association :section
  end

  factory :time_slot do
    day { 'Monday' }
    start_time { '09:00' }
    end_time { '10:00' }
    slot_type { 'Lecture' }
  end

  factory :instructor_preference do
    association :instructor
    association :course
    preference_level { '2' }
  end
end
