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
end
